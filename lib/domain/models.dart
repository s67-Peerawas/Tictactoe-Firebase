import 'package:flutter/foundation.dart';

// เดิมมี const boardSize = 3; -> ไม่ใช้แล้ว (ลบออกได้)

class GameState {
  final List<String> board;   // ความยาว = size*size
  final String turn;
  final String winner;
  final String xPlayerId;
  final String oPlayerId;

  /// ✅ ขนาดกระดานแบบไดนามิก
  final int size;

  const GameState({
    required this.board,
    required this.turn,
    required this.winner,
    required this.xPlayerId,
    required this.oPlayerId,
    required this.size,
  });

  /// สร้างสถานะว่างด้วยขนาด N (ค่าเริ่มต้น 3)
  factory GameState.empty({int size = 3}) => GameState(
        board: List.filled(size * size, ""),
        turn: "X",
        winner: "",
        xPlayerId: "",
        oPlayerId: "",
        size: size,
      );

  List<List<String>> get board2D =>
      List.generate(size, (r) => board.sublist(r * size, (r + 1) * size));

  GameState copyWith({
    List<String>? board,
    String? turn,
    String? winner,
    String? xPlayerId,
    String? oPlayerId,
    int? size, // ถ้าจะเปลี่ยน size ให้เปลี่ยนคู่กับ board ให้พอดี
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      winner: winner ?? this.winner,
      xPlayerId: xPlayerId ?? this.xPlayerId,
      oPlayerId: oPlayerId ?? this.oPlayerId,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() => {
        "board": board,
        "turn": turn,
        "winner": winner,
        "players": {"X": xPlayerId, "O": oPlayerId},
        "size": size, // ✅ เก็บลง DB ด้วย
      };

  static GameState fromMap(Map<String, dynamic> m) {
    final players = (m["players"] as Map?) ?? {};
    final sz = (m["size"] ?? 3) as int;
    final list = (m["board"] as List).map((e) => e.toString()).toList();
    // เผื่อกรณีขนาดใน DB ไม่ครบ
    final want = sz * sz;
    final fixed = (list.length == want) ? list : List.filled(want, "");

    return GameState(
      board: fixed,
      turn: (m["turn"] ?? "X").toString(),
      winner: (m["winner"] ?? "").toString(),
      xPlayerId: (players["X"] ?? "").toString(),
      oPlayerId: (players["O"] ?? "").toString(),
      size: sz,
    );
  }
}

