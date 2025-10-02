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
  Future<String> ensureGame({required String gameId, required String playerId}) async {
    final d = await _doc(gameId).get();
    if (!d.exists) {
      await _doc(gameId).set(GameState.empty().copyWith(
        xPlayerId: playerId,
      ).toMap());
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

      if (!isInsideBoard(row, col) || s.winner.isNotEmpty) return;
      final mySymbol = (s.xPlayerId == playerId) ? "X" : (s.oPlayerId == playerId ? "O" : "");
      if (mySymbol.isEmpty || s.turn != mySymbol) return;

      final idx = rcToIndex(row, col);
      if (s.board[idx].isNotEmpty) return;

      final newBoard = [...s.board]..[idx] = mySymbol;
      final new2D = List.generate(boardSize, (r) => newBoard.sublist(r*boardSize, (r+1)*boardSize));
      final w = checkWinner(new2D);
      final next = (mySymbol == "X") ? "O" : "X";

      s = s.copyWith(board: newBoard, winner: w, turn: w.isEmpty ? next : s.turn);
      tx.update(ref, s.toMap());
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
      final reset = GameState.empty().copyWith(
        xPlayerId: s.xPlayerId, // คงผู้เล่นเดิม
        oPlayerId: s.oPlayerId, // คงผู้เล่นเดิม
      );
      tx.set(ref, reset.toMap());
    });
  }
}
