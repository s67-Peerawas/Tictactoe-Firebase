import 'dart:async';
import '../domain/models.dart';
import '../domain/game_logic.dart';
import 'game_repository.dart';

class LocalGameRepository implements GameRepository {
  final _games = <String, GameState>{};
  final _controllers = <String, StreamController<GameState>>{};

  StreamController<GameState> _controllerFor(String id) =>
      _controllers.putIfAbsent(id, () => StreamController<GameState>.broadcast());

  GameState _stateFor(String id) => _games.putIfAbsent(id, () => GameState.empty());

  void _emit(String id, GameState s) {
    _games[id] = s;
    _controllerFor(id).add(s);
  }

  @override
  Future<String> ensureGame({required String gameId, required String playerId}) async {
    final s = _stateFor(gameId);
    if (s.xPlayerId.isEmpty) {
      _emit(gameId, s.copyWith(xPlayerId: playerId));
      return "X";
    } else if (s.oPlayerId.isEmpty && s.xPlayerId != playerId) {
      _emit(gameId, s.copyWith(oPlayerId: playerId));
      return "O";
    }
    return s.xPlayerId == playerId ? "X" : "O";
  }

  @override
  Stream<GameState> watchGame(String gameId) {
    Future.microtask(() => _emit(gameId, _stateFor(gameId)));
    return _controllerFor(gameId).stream;
  }

  @override
  Future<void> makeMove({
    required String gameId,
    required String playerId,
    required int row,
    required int col,
  }) async {
    var s = _stateFor(gameId);
    final n = s.size;
    if (!isInsideBoard(row, col, n) || s.winner.isNotEmpty) return;

    final mySymbol = (s.xPlayerId == playerId) ? "X" : (s.oPlayerId == playerId ? "O" : "");
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
    _emit(gameId, s);
  }

  @override
  Future<void> resetGame(String gameId) async {
    final s = _stateFor(gameId);
    _emit(
      gameId,
      GameState.empty(size: s.size).copyWith( // ✅ คง size
        xPlayerId: s.xPlayerId,
        oPlayerId: s.oPlayerId,
      ),
    );
  }
}