// lib/ui/online_game_page.dart
import 'package:flutter/material.dart';
import '../data/firestore_game_repository.dart';
import '../domain/mark.dart';
import 'board_painter.dart';

class OnlineGamePage extends StatefulWidget {
  final FirestoreGameRepository repo;
  final String gameId;
  final String playerId;

  const OnlineGamePage({
    super.key,
    required this.repo,
    required this.gameId,
    required this.playerId,
  });

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  late Stream<GameState> _stream;
  String mySymbol = '';
  String status = 'joining...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final s = await widget.repo.ensureGame(
        gameId: widget.gameId,
        playerId: widget.playerId,
      );
      if (!mounted) return;
      setState(() {
        mySymbol = s;
        status = 'joined as $s';
      });
      _stream = widget.repo.watchGame(widget.gameId);
      setState(() {}); // trigger build StreamBuilder
    } catch (e) {
      if (!mounted) return;
      setState(() {
        status = 'join failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ถ้า stream ยังไม่พร้อม (ยัง join ไม่สำเร็จ) ก็แสดงสถานะไปก่อน
    if (mySymbol.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Online: ...')),
        body: Center(child: Text(status)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Online: $mySymbol')),
      body: StreamBuilder<GameState>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('stream error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snap.data!;
          final marks = <Mark>[];
          for (int r = 0; r < state.board.length; r++) {
            for (int c = 0; c < state.board[r].length; c++) {
              final v = state.board[r][c];
              if (v.isNotEmpty) marks.add(Mark(row: r, col: c, type: v));
            }
          }

          final info = 'next: ${state.nextTurn} | winner: ${state.winner.isEmpty ? "-": state.winner}';
          final side = MediaQuery.of(context).size.shortestSide - 24;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(info, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTapDown: (d) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(d.globalPosition);
                      _handleTap(local, Size(side, side), state);
                    },
                    child: CustomPaint(
                      size: Size(side, side),
                      painter: BoardPainter(
                        markSize: side / (state.board.length * 4),
                        gridSize: state.board.length,
                        marks: marks,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleTap(Offset local, Size boardSize, GameState state) {
    final n = state.board.length;
    final cellW = boardSize.width / n;
    final cellH = boardSize.height / n;
    final col = (local.dx / cellW).floor().clamp(0, n - 1);
    final row = (local.dy / cellH).floor().clamp(0, n - 1);

    widget.repo.makeMove(
      gameId: widget.gameId,
      playerId: widget.playerId,
      row: row,
      col: col,
    ).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('move failed: $e')),
      );
    });
  }
}
