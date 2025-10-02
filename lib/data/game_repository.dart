import '../domain/models.dart';

abstract class GameRepository {
  /// เตรียมเกม + ระบุตัวตนผู้เล่น (สร้าง/เข้าร่วม)
  Future<String> ensureGame({required String gameId, required String playerId});

  /// สตรีมสถานะเกม
  Stream<GameState> watchGame(String gameId);

  /// เดินหมาก
  Future<void> makeMove({
    required String gameId,
    required String playerId,
    required int row,
    required int col,
  });

  /// รีเซ็ตเกม
  Future<void> resetGame(String gameId);
}
