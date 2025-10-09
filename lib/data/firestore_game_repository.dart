import 'package:cloud_firestore/cloud_firestore.dart';

class GameState {
  final List<List<String>> board;
  final String nextTurn; // 'X' | 'O'
  final String winner;   // '', 'X', 'O', 'DRAW'

  GameState({
    required this.board,
    required this.nextTurn,
    required this.winner,
  });
}

class FirestoreGameRepository {
  final FirebaseFirestore _db;
  FirestoreGameRepository(this._db);

  DocumentReference<Map<String, dynamic>> _doc(String id) =>
      _db.collection('games').doc(id);

  Future<String> ensureGame({
    required String gameId,
    required String playerId,
  }) async {
    final ref = _doc(gameId);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'board': List.generate(3, (_) => List.filled(3, '')),
          'nextTurn': 'O',
          'winner': '',
          'players': {'O': playerId, 'X': ''},
        });
        return 'O';
      } else {
        final data = snap.data()!;
        final players = Map<String, dynamic>.from(data['players'] ?? {'O': '', 'X': ''});
        if (players['O'] == '' && players['X'] != playerId) {
          players['O'] = playerId;
          tx.update(ref, {'players': players});
          return 'O';
        }
        if (players['X'] == '' && players['O'] != playerId) {
          players['X'] = playerId;
          tx.update(ref, {'players': players});
          return 'X';
        }
        if (players['O'] == playerId) return 'O';
        if (players['X'] == playerId) return 'X';
        throw Exception('Room is full');
      }
    });
  }

  Stream<GameState> watchGame(String gameId) {
    return _doc(gameId).snapshots().map((snap) {
      final d = snap.data() ?? {};
      final raw = (d['board'] as List<dynamic>? ?? []);
      final board = raw.map((r) => (r as List<dynamic>).map((e) => e?.toString() ?? '').toList()).toList();
      final nextTurn = (d['nextTurn'] ?? 'O').toString();
      final winner = (d['winner'] ?? '').toString();
      return GameState(board: board.cast<List<String>>(), nextTurn: nextTurn, winner: winner);
    });
  }

  Future<void> makeMove({
    required String gameId,
    required String playerId,
    required int row,
    required int col,
  }) async {
    final ref = _doc(gameId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw Exception('Game not found');
      final d = snap.data()!;
      final board = (d['board'] as List).map((r) => List<String>.from(r)).toList();
      final nextTurn = d['nextTurn'] as String? ?? 'O';
      final winner = d['winner'] as String? ?? '';
      final players = Map<String, dynamic>.from(d['players'] ?? {});

      if (winner.isNotEmpty) return;

      final myEntry = players.entries.firstWhere(
        (e) => e.value == playerId,
        orElse: () => const MapEntry('?', '?'),
      );
      final mySymbol = myEntry.key;
      if (mySymbol != nextTurn) return;
      if (board[row][col] != '') return;

      board[row][col] = mySymbol;

      String newWinner = _winnerOf(board);
      String newNext = mySymbol == 'O' ? 'X' : 'O';
      if (newWinner.isNotEmpty) {
        // game over → nextTurn no change
      } else if (_isDraw(board)) {
        newWinner = 'DRAW';
      } else {
        // continue
      }

      tx.update(ref, {
        'board': board,
        'nextTurn': newWinner.isEmpty ? newNext : nextTurn,
        'winner': newWinner,
      });
    });
  }

  // ----- helpers -----
  String _winnerOf(List<List<String>> b) {
    const empty = '';
    final n = b.length;
    bool eq(List<String> line) =>
        line.isNotEmpty && line[0] != empty && line.every((e) => e == line[0]);

    for (int i = 0; i < n; i++) {
      if (eq(b[i])) return b[i][0];
      final col = [for (int r = 0; r < n; r++) b[r][i]];
      if (eq(col)) return col[0];
    }
    final d1 = [for (int i = 0; i < n; i++) b[i][i]];
    if (eq(d1)) return d1[0];
    final d2 = [for (int i = 0; i < n; i++) b[i][n - 1 - i]];
    if (eq(d2)) return d2[0];
    return '';
  }

  bool _isDraw(List<List<String>> b) {
    for (final r in b) {
      for (final c in r) {
        if (c == '') return false;
      }
    }
    return _winnerOf(b).isEmpty;
  }
}
