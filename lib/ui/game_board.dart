import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/models.dart';
import 'game_controller.dart';
import 'grid_painter.dart';

const xColor = Colors.blue;
const oColor = Colors.red;

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GameController>();
    final s = c.state;

    final boardPx = MediaQuery.of(context).size.width;
    final n = s.size;             // ✅ ใช้ขนาดจากสถานะ
    final cell = boardPx / n;

    return Scaffold(
      appBar: AppBar(title: const Text("TicTacToe")),
      body: Column(
        children: [
          SizedBox(height: 8),
          SizedBox(
            width: boardPx,
            height: boardPx,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final dx = d.localPosition.dx.clamp(0, boardPx - 0.0001);
                final dy = d.localPosition.dy.clamp(0, boardPx - 0.0001);
                final col = (dx / cell).floor();
                final row = (dy / cell).floor();

                final c = context.read<GameController>();
                final s = c.state;
                if (row >= 0 && col >= 0 && row < n && col < n) {
                  if (s.winner.isEmpty && s.turn == c.mySymbol) {
                    c.tapCell(row, col);
                  }
                }
              },
              child: Stack(
                children: [
                  CustomPaint(size: Size(boardPx, boardPx), painter: GridPainter(n: n)),
                  ...List.generate(n, (r) {
                    return List.generate(n, (q) {
                      final mark = s.board2D[r][q];
                      if (mark.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        left: q * cell,
                        top: r * cell,
                        width: cell,
                        height: cell,
                        child: Center(
                          child: Text(
                            mark,
                            style: TextStyle(
                              fontSize: cell / 1.5,
                              fontWeight: FontWeight.bold,
                              color: mark == 'X' ? xColor : oColor,
                            ),
                          ),
                        ),
                      );
                    });
                  }).expand((e) => e).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("You are: ${c.mySymbol}", style: const TextStyle(fontSize: 20)),
          Text("Turn: ${s.turn}", style: const TextStyle(fontSize: 20)),
          if (s.winner.isNotEmpty)
            Text("Winner: ${s.winner}", style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: c.reset, child: const Text("Reset Game")),
        ],
      ),
    );
  }
}
