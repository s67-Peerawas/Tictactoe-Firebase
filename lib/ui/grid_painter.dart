import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final int n;
  GridPainter({required this.n});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2;

    final w = size.width;
    final h = size.height;
    final cw = w / n;
    final ch = h / n;

    // วาดเส้นระหว่างช่อง (ไม่ทับขอบทั้งหมด)
    for (int i = 1; i < n; i++) {
      final x = cw * i;
      final y = ch * i;
      canvas.drawLine(Offset(x, 0), Offset(x, h), p); // แนวตั้ง
      canvas.drawLine(Offset(0, y), Offset(w, y), p); // แนวนอน
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => oldDelegate.n != n;
}
