import 'package:flutter/material.dart';

class LineGraphPainter extends CustomPainter {
  final Color graphColor;
  final int lineCount;

  LineGraphPainter({required this.graphColor, required this.lineCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = graphColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    const List<double> data = [0.4, 0.6, 0.3, 0.7, 0.5, 0.8, 0.4];

    final double stepX = size.width / (lineCount - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - data[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}