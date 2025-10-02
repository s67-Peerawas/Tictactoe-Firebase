import 'package:flutter/foundation.dart';
import '../data/game_repository.dart';
import '../domain/models.dart';

class GameController extends ChangeNotifier {
  final GameRepository repo;
  final String gameId;
  final String playerId;
  GameController({required this.repo, required this.gameId, required this.playerId});

  String mySymbol = "";
  GameState _state = GameState.empty();
  GameState get state => _state;

  late final _sub = repo.watchGame(gameId).listen((s) {
    _state = s;
    notifyListeners();
  });

  Future<void> init() async {
    mySymbol = await repo.ensureGame(gameId: gameId, playerId: playerId);
    notifyListeners();
  }

  Future<void> tapCell(int row, int col) async {
    await repo.makeMove(gameId: gameId, playerId: playerId, row: row, col: col);
  }

  Future<void> reset() => repo.resetGame(gameId);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}