import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as model;

class PostCard extends StatelessWidget {
  final model.ForumEntry post;

  const PostCard({super.key, required this.post});

  // 1. REUSE THIS LOGIC: This is critical for the app to work on Android Emulator
  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }

  @override
  Widget build(BuildContext context) {
    // 2. SAFE IMAGE LOGIC: Handle relative URLs correctly
    String? imageUrl;
    if (post.images.isNotEmpty) {
      // Use the friend's sorting logic if order matters
      // post.images.sort((a, b) => a.order.compareTo(b.order));
      String rawUrl = post.images.first.url;

      if (rawUrl.startsWith('http')) {
        imageUrl = rawUrl;
      } else {
        // If it's a relative path (e.g. /media/...), append base URL
        imageUrl = "$_baseUrl$rawUrl";
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Badges / Clubs ---
            if (post.clubs.isNotEmpty)
              Wrap(
                spacing: 8,
                children: post.clubs.map((club) {
                  // NOTE: If your friend is right, 'club' is just an ID (int/string).
                  // We can try to load the logo using their logic, or just show the ID.
                  // This hybrid approach tries to show a logo, falls back to text.
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Try to load club logo like your friend does
                        Image.network(
                          '$_baseUrl/media/club_logos/$club.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.shield,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Display ID or Name if you have it.
                        // If club is just an ID, we display "Club $club"
                        Text(
                          "Club $club",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),

            // --- Title ---
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFE8800),
              ),
            ),

            // --- Date ---
            Text(
              // Using DateFormat is cleaner than manual string interpolation
              "${post.createdAt.day}-${post.createdAt.month}-${post.createdAt.year}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // --- Image ---
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],

            // --- Content ---
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            // --- Footer ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Show comment count like friend's widget?
                Row(
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${post.comments.length}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to detail page logic here
                  },
                  child: const Text(
                    "Read more →",
                    style: TextStyle(color: Color(0xFFFE8800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
