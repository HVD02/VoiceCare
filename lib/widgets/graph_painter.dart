import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  final List<double> points;

  GraphPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final actualPoints = points.asMap().entries.map((entry) {
      final index = entry.key;
      final normalizedY = entry.value;
      final x = (size.width / (points.length - 1)) * index;
      final y = size.height * (1.0 - normalizedY);
      return Offset(x, y);
    }).toList();

    path.moveTo(actualPoints.first.dx, actualPoints.first.dy);
    for (int i = 1; i < actualPoints.length; i++) {
      path.lineTo(actualPoints[i].dx, actualPoints[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}