import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/profile/models/activity_models.dart';

class ClubGridItem extends StatelessWidget {
  final LeaguePick club; // Changed from Club to LeaguePick

  const ClubGridItem({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: InkWell(
        onTap: () {
          // Navigation logic
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                    (club
                        .logoUrl
                        .isNotEmpty) // LeaguePick logoUrl is String (not nullable in your model)
                    ? Image.network(
                        club.logoUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.shield,
                              size: 50,
                              color: Colors.grey,
                            ),
                      )
                    : const Icon(Icons.shield, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                club.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
