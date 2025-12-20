import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as forum_model;
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

class PostDetailPage extends StatefulWidget {
  final forum_model.ForumEntry post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int _currentImageIndex = 0;
  final TextEditingController _commentController = TextEditingController();

  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "http://localhost:8000";
  }

  @override
  void initState() {
    super.initState();
    widget.post.images.sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % widget.post.images.length;
    });
  }

  void _previousImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex - 1 + widget.post.images.length) % widget.post.images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isEdited = widget.post.updatedAt.difference(widget.post.createdAt).inSeconds > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.post.title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.author,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: DateFormat('MMM d, yyyy, h:mm a').format(isEdited ? widget.post.updatedAt : widget.post.createdAt),
                            ),
                            if (isEdited)
                              const TextSpan(
                                text: ' (edited)',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                        style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: widget.post.clubs.map((club) {
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
            const SizedBox(height: 16.0),

            // Title
            Text(
              widget.post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            const SizedBox(height: 16.0),

            // Image Carousel
            if (widget.post.images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(widget.post.images[_currentImageIndex].url)}',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.error, color: Colors.red)),
                        ),
                      ),
                      if (widget.post.images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: _previousImage),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white), onPressed: _nextImage),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.post.images[_currentImageIndex].caption,
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),

            // Content
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const Divider(height: 40, thickness: 1),

            // Add Comment Form
            if (request.loggedIn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add a Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                const SizedBox(height: 12.0),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your comment'),
                  maxLines: 1,
                ),
                const SizedBox(height: 8.0),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final content = _commentController.text;
                      if (content.isNotEmpty) {
                        // ======== BYPASS TEST USER =========
                        // try {
                        //   final Map<String, dynamic> requestBody = {
                        //     'content': content,
                        //   };
                        //
                        //   final response = await http.post(
                        //     Uri.parse('$_baseUrl/forum/api/post/${widget.post.id}/comment/create/flutter/'),
                        //     headers: {"Content-Type": "application/json"},
                        //     body: jsonEncode(requestBody),
                        //   );
                        //
                        //   final responseData = jsonDecode(response.body);
                        //
                        //   if ((response.statusCode == 200 || response.statusCode == 201) && responseData['status'] == 'success') {
                        //     setState(() {
                        //       widget.post.comments.add(forum_model.Comment.fromJson(responseData['comment']));
                        //       _commentController.clear();
                        //     });
                        //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //       content: Text("Comment added successfully!"),
                        //       backgroundColor: Colors.green,
                        //     ));
                        //   } else {
                        //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //       content: Text("Error: ${responseData['message'] ?? 'Failed to add comment'}"),
                        //       backgroundColor: Colors.red,
                        //     ));
                        //   }
                        // } catch (e) {
                        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //     content: Text("An unexpected error occurred: $e"),
                        //     backgroundColor: Colors.red,
                        //   ));
                        // }


                        // print($user_id: request.jsonData['id'], $content: content);
                        final response = await request.post(
                          '$_baseUrl/forum/api/post/${widget.post.id}/comment/create/flutter/',
                          {
                            'content': content,
                          },
                        );
                        if (response['status'] == 'success') {
                          setState(() {
                            widget.post.comments.add(forum_model.Comment.fromJson(response['comment']));
                            _commentController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Comment added successfully!"),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error: ${response['message'] ?? 'Failed to add comment'}"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
            if (!request.loggedIn)
            const Text('You must be logged in to add a comment.'),

            const SizedBox(height: 24.0),

            // Comments Section
            Text(
              'Comments (${widget.post.comments.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            const SizedBox(height: 16.0),
            if (widget.post.comments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No comments yet.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.post.comments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text(DateFormat('MMM d, yyyy, h:mm a').format(comment.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12.0)),
                        const SizedBox(height: 8.0),
                        Text(comment.content),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 12.0),

          ],
        ),
      ),
    );
  }
}
