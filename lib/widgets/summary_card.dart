import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color textMutedColor;
  final String title;
  final String description;

  const SummaryCard({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.textMutedColor,
    required this.title,
    required this.description,
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
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: textMutedColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}