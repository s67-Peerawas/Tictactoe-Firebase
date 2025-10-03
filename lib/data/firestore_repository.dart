import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/models.dart';
import '../domain/game_logic.dart';
import 'game_repository.dart';

class FirestoreGameRepository implements GameRepository {
  final FirebaseFirestore firestore;
  FirestoreGameRepository(this.firestore);

  DocumentReference<Map<String, dynamic>> _doc(String id) =>
      firestore.collection('games').doc(id);

  @override
  Future<String> ensureGame({
    required String gameId,
    required String playerId,
  }) async {
    final d = await _doc(gameId).get();
    if (!d.exists) {

      final first = GameState.empty(size: 3).copyWith(xPlayerId: playerId);
      await _doc(gameId).set(first.toMap());
      return "X";
    }

    final s = GameState.fromMap(d.data()!);
    if (s.oPlayerId.isEmpty && s.xPlayerId != playerId) {
      await _doc(gameId).update({"players.O": playerId});
      return "O";
    }
    return s.xPlayerId == playerId ? "X" : "O";
  }

  @override
  Stream<GameState> watchGame(String gameId) {
    return _doc(gameId).snapshots().map((snap) {
      if (!snap.exists) return GameState.empty();
      return GameState.fromMap(snap.data()!);
    });
  }

  @override
  Future<void> makeMove({
    required String gameId,
    required String playerId,
    required int row,
    required int col,
  }) async {
    await firestore.runTransaction((tx) async {
      final ref = _doc(gameId);
      final snap = await tx.get(ref);
      GameState s = snap.exists ? GameState.fromMap(snap.data()!) : GameState.empty();

      final n = s.size;

      if (!isInsideBoard(row, col, n) || s.winner.isNotEmpty) return;

      final mySymbol =
          (s.xPlayerId == playerId) ? "X" : (s.oPlayerId == playerId ? "O" : "");
      if (mySymbol.isEmpty || s.turn != mySymbol) return;

      final idx = rcToIndex(row, col, n);
      if (s.board[idx].isNotEmpty) return;

      final newBoard = [...s.board]..[idx] = mySymbol;
      final new2D = List.generate(n, (r) => newBoard.sublist(r * n, (r + 1) * n));
      final w = checkWinner(new2D);
      final next = (mySymbol == "X") ? "O" : "X";

      s = s.copyWith(
        board: newBoard,
        winner: w,
        turn: w.isEmpty ? next : s.turn,
      );

      if (snap.exists) {
        tx.update(ref, s.toMap());
      } else {
        tx.set(ref, s.toMap());
      }
    });
  }

  @override
  Future<void> resetGame(String gameId) async {
    final ref = _doc(gameId);
    await firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, GameState.empty().toMap());
        return;
      }
      final s = GameState.fromMap(snap.data()!);
      final reset = GameState.empty(size: s.size).copyWith( 
        xPlayerId: s.xPlayerId,
        oPlayerId: s.oPlayerId,
      );
      tx.set(ref, reset.toMap());
    });
  }
}
