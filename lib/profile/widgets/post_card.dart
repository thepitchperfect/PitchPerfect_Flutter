import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/profile/models/activity_models.dart';

class PostCard extends StatelessWidget {
  final UserPost post; // Changed to UserPost

  const PostCard({super.key, required this.post});

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
    // 1. Image Handling
    String? imageUrl;
    if (post.images.isNotEmpty) {
      // Because images is List<dynamic>, we treat it as a Map
      final firstImage = post.images.first;
      // Check if 'url' exists in the map, otherwise handle gracefully
      String rawUrl = (firstImage is Map && firstImage.containsKey('url'))
          ? firstImage['url']
          : '';

      if (rawUrl.isNotEmpty) {
        if (rawUrl.startsWith('http')) {
          imageUrl = rawUrl;
        } else {
          imageUrl = "$_baseUrl$rawUrl";
        }
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
      child: InkWell(
        onTap: () {
          // Navigate to Post Detail
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Badges / Clubs ---
              if (post.clubs.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: post.clubs.map((club) {
                    // Because clubs is List<dynamic>, we treat it as a Map
                    String clubName = (club is Map && club.containsKey('name'))
                        ? club['name']
                        : 'Unknown Club';

                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Club $clubName",
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
              ],

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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
