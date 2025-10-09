import 'package:flutter/material.dart';
import '../domain/mark.dart';

class BoardPainter extends CustomPainter {
  final double markSize;    // ขนาดเครื่องหมาย
  final int gridSize;       // ขนาดตาราง (เช่น 3, 5, 7)
  final List<Mark> marks;   // ตำแหน่ง X/O ที่วางแล้ว

  BoardPainter({
    required this.markSize,
    required this.gridSize,
    required this.marks,
  });

  // ✅ เหลือ paint() แค่อันเดียว
  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridSize;
    final cellH = size.height / gridSize;

    final gridPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // เส้นแนวนอน/แนวตั้ง
    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(Offset(0, cellH * i), Offset(size.width, cellH * i), gridPaint);
      canvas.drawLine(Offset(cellW * i, 0), Offset(cellW * i, size.height), gridPaint);
    }

    // เส้นกรอบ
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gridPaint);

    // วาดเครื่องหมาย
    for (final m in marks) {
      final cx = m.col * cellW + cellW / 2;
      final cy = m.row * cellH + cellH / 2;
      final pos = Offset(cx, cy);
      if (m.type == 'O') {
        _drawO(canvas, pos);
      } else {
        _drawX(canvas, pos);
      }
    }
  }

  void _drawO(Canvas canvas, Offset pos) {
    final p = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pos, markSize, p);
  }

  void _drawX(Canvas canvas, Offset pos) {
    final p = Paint()
      ..color = Colors.red
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final s = markSize * 1.1;
    canvas.drawLine(Offset(pos.dx - s, pos.dy - s), Offset(pos.dx + s, pos.dy + s), p);
    canvas.drawLine(Offset(pos.dx - s, pos.dy + s), Offset(pos.dx + s, pos.dy - s), p);
  }

  // ✅ เพิ่ม shouldRepaint ให้ครบ
  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.markSize != markSize ||
        oldDelegate.marks != marks;
  }
}
