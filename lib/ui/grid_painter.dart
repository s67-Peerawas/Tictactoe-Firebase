import 'package:flutter/material.dart';
import '../domain/models.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..strokeWidth = 3.0;
    final cw = size.width / boardSize;
    final ch = size.height / boardSize;

    for (int i = 0; i <= boardSize; i++) {
      canvas.drawLine(Offset(0, ch * i), Offset(size.width, ch * i), p);
      canvas.drawLine(Offset(cw * i, 0), Offset(cw * i, size.height), p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}