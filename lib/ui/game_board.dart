import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models.dart';
import 'game_controller.dart';
import 'grid_painter.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GameController>();
    final s = c.state;

    final size = MediaQuery.of(context).size.width;
    final cell = size / boardSize;

    return Scaffold(
      appBar: AppBar(title: const Text("TicTacToe")),
      body: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: GestureDetector(
              onTapDown: (d) {
                final col = (d.localPosition.dx / cell).floor();
                final row = (d.localPosition.dy / cell).floor();
                if (row >= 0 && col >= 0 && row < boardSize && col < boardSize) {
                  if (s.winner.isEmpty && s.turn == c.mySymbol) {
                    c.tapCell(row, col);
                  }
                }
              },
              child: Stack(
                children: [
                  CustomPaint(size: Size(size, size), painter: GridPainter()),
                  ...List.generate(boardSize, (r) {
                    return List.generate(boardSize, (q) {
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
