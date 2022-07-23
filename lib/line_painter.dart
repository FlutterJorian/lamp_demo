import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  LinePainter({
    required this.from,
    required this.to,
  });

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xfffcf72c)
      ..strokeWidth = 2.5;

    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
