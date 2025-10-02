// lib/ui/game_controller.dart
import 'dart:async';                         // ✅ สำหรับ StreamSubscription
import 'package:flutter/foundation.dart';
import '../data/game_repository.dart';
import '../domain/models.dart';

class GameController extends ChangeNotifier {
  GameController({
    required this.repo,
    required this.gameId,
    required this.playerId,
  });

  final GameRepository repo;
  final String gameId;
  final String playerId;

  GameState _state = GameState.empty();
  GameState get state => _state;

  String mySymbol = "";                      // 'X' | 'O'
  StreamSubscription<GameState>? _sub;

  /// เรียกจาก main.dart ตอนสร้าง Provider: ..init()
  Future<void> init() async {
    // 1) สมัครเข้าห้อง → ได้สัญลักษณ์ของเรา
    mySymbol = await repo.ensureGame(gameId: gameId, playerId: playerId);

    // 2) ฟังสถานะเกมจาก data layer
    _sub?.cancel();
    _sub = repo.watchGame(gameId).listen((s) {
      _state = s;
      notifyListeners();
    });
  }

  /// แตะช่อง (เรียกจาก GameBoard)
  Future<void> tapCell(int row, int col) async {
    // ปล่อยให้ repo ตรวจเงื่อนไขตา/ผู้ชนะซ้ำอีกชั้น
    await repo.makeMove(
      gameId: gameId,
      playerId: playerId,
      row: row,
      col: col,
    );
  }

  /// ปุ่ม Reset (ที่คุณเรียก c.reset)
  Future<void> reset() async {
    await repo.resetGame(gameId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
