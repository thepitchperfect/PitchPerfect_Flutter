import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/clubdirectory/models/club_model.dart';

class ClubGridItem extends StatelessWidget {
  final Club club;

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
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: club.logoUrl != null
                    ? Image.network(
                        club.logoUrl!,
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
