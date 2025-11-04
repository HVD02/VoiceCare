import 'package:flutter/material.dart';
import 'line_graph_painter.dart';

class WellnessTrendCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color textMutedColor;
  final Color primaryColor;

  const WellnessTrendCard({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.textMutedColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Wellness Trend',
            style: TextStyle(
              color: textMutedColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '7 Day Avg',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '-5%',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'This Week',
                style: TextStyle(
                  color: textMutedColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: LineGraphPainter(
                graphColor: primaryColor,
                lineCount: 7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mon', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Tue', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Wed', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Thu', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Fri', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Sat', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
              Text('Sun', style: TextStyle(color: Color(0xFF616161), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}