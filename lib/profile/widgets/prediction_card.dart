import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/profile/models/activity_models.dart';

class PredictionCard extends StatelessWidget {
  final UserPrediction prediction; // Changed to UserPrediction

  const PredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Title
          Text(
            prediction.matchTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // User Pick
          Text(
            "Your pick: ${prediction.votedFor}",
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Date (Formatted)
          Text(
            "${prediction.matchDate.year}-${prediction.matchDate.month.toString().padLeft(2, '0')}-${prediction.matchDate.day.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
