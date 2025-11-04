import 'package:flutter/material.dart';
import '../models/health_log_data.dart';
import 'graph_painter.dart';

class WeeklyReportCard extends StatelessWidget {
  final WeeklyReportData reportData;

  const WeeklyReportCard({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reportData.title,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            reportData.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                reportData.summaryDuration,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                reportData.change,
                style: TextStyle(color: reportData.changeColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD54F).withAlpha(64),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomPaint(
              painter: GraphPainter(reportData.graphPoints),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: reportData.graphLabels
                .map((label) => Text(
                      label,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}