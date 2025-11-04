import 'package:flutter/material.dart';

class SymptomProgressBar extends StatelessWidget {
  final String symptom;
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  final Color textColor;

  const SymptomProgressBar({
    super.key,
    required this.symptom,
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          symptom,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}