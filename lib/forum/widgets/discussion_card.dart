import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as forum_model;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:pitch_perfect_flutter/forum/screens/post_detail.dart';

class DiscussionCard extends StatelessWidget {
  final forum_model.ForumEntry post;

  const DiscussionCard({super.key, required this.post});

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
    if (post.images.isNotEmpty) {
      post.images.sort((a, b) => a.order.compareTo(b.order));
    }

    final imageUrl = post.images.isNotEmpty
        ? '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(post.images[0].url)}'
        : null;

    final bool isEdited = post.updatedAt.difference(post.createdAt).inSeconds > 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: post),
          ),
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: DateFormat('MMM d, yyyy').format(isEdited ? post.updatedAt : post.createdAt),
                              ),
                              if (isEdited)
                                const TextSpan(
                                  text: ' (edited)',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: post.clubs.map((club) {
                      final logoUrl = club.logoUrl;

                      if (logoUrl == null || logoUrl.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.network(
                          '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(logoUrl)}',
                          height: 30,
                          width: 30,
                          errorBuilder: (context, error, stackTrace) {
                            print("Failed to load image: $logoUrl, Error: $error");
                            return const Icon(Icons.shield, size: 30, color: Colors.grey);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 12.0),
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      );
                    },
                  ),
                )
              else
                Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.0),
                ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.comment, color: Colors.grey, size: 20),
                  const SizedBox(width: 4.0),
                  Text(
                    post.comments.length.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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
