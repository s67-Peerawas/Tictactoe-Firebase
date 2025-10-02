import 'package:flutter/foundation.dart';

const int boardSize = 3;

@immutable
class GameState {
  final List<String> board; // length = boardSize*boardSize, "" | "X" | "O"
  final String turn;        // "X" | "O"
  final String winner;      // "" | "X" | "O" | "Tie"
  final String xPlayerId;   // อาจเป็น "" ถ้ายังไม่ join
  final String oPlayerId;

  const GameState({
    required this.board,
    required this.turn,
    required this.winner,
    required this.xPlayerId,
    required this.oPlayerId,
  });

  factory GameState.empty() => GameState(
        board: List.filled(boardSize * boardSize, ""),
        turn: "X",
        winner: "",
        xPlayerId: "",
        oPlayerId: "",
      );

  List<List<String>> get board2D => List.generate(
        boardSize,
        (r) => board.sublist(r * boardSize, (r + 1) * boardSize),
      );

  GameState copyWith({
    List<String>? board,
    String? turn,
    String? winner,
    String? xPlayerId,
    String? oPlayerId,
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      winner: winner ?? this.winner,
      xPlayerId: xPlayerId ?? this.xPlayerId,
      oPlayerId: oPlayerId ?? this.oPlayerId,
    );
  }

  Map<String, dynamic> toMap() => {
        "board": board,
        "turn": turn,
        "winner": winner,
        "players": {"X": xPlayerId, "O": oPlayerId},
      };

  static GameState fromMap(Map<String, dynamic> m) {
    final players = (m["players"] as Map?) ?? {};
    return GameState(
      board: (m["board"] as List).map((e) => e.toString()).toList(),
      turn: (m["turn"] ?? "X").toString(),
      winner: (m["winner"] ?? "").toString(),
      xPlayerId: (players["X"] ?? "").toString(),
      oPlayerId: (players["O"] ?? "").toString(),
    );
    }
}
