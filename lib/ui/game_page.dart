import 'package:flutter/material.dart';
import '../domain/game_logic.dart';
import 'board_painter.dart';

class GamePage extends StatefulWidget {
  final int gridSize;
  const GamePage({super.key, this.gridSize = 5}); 

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameLogic logic;

  @override
  void initState() {
    super.initState();
    logic = GameLogic(gridSize: widget.gridSize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TicTacToe ${logic.gridSize}x${logic.gridSize} (Local)'),
        actions: [
          IconButton(
            onPressed: () => setState(() => logic.clearBoard()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, cstr) {
          final side = cstr.biggest.shortestSide - 24; // ขนาดกระดาน
          return Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                // ใช้ localPosition ตรง ๆ และให้พื้นที่รับทัชเท่ากระดาน
                final local = details.localPosition;
                _handleTap(local, Size(side, side));
              },
              child: SizedBox.square(
                dimension: side, // พื้นที่รับทัช = กระดาน
                child: CustomPaint(
                  size: Size(side, side),
                  painter: BoardPainter(
                    markSize: side / (logic.gridSize * 4),
                    gridSize: logic.gridSize,
                    marks: logic.marks,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              logic.isGameOver
                  ? 'Game Over: ${logic.winner}'
                  : 'Turn: ${logic.currentTurn}',
            ),
            ElevatedButton(
              onPressed: () => setState(() => logic.clearBoard()),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset local, Size boardSize) {
    final n = logic.gridSize;
    final cellW = boardSize.width / n;
    final cellH = boardSize.height / n;

    // กันหลุดขอบ (แตะชายขอบ)
    final dx = local.dx.clamp(0, boardSize.width - 0.001);
    final dy = local.dy.clamp(0, boardSize.height - 0.001);

    final col = (dx / cellW).floor().clamp(0, n - 1);
    final row = (dy / cellH).floor().clamp(0, n - 1);

    setState(() {
      logic.placeMark(row, col);
    });
  }
}
