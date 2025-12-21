import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pitch_perfect_flutter/clubdirectory/models/club_model.dart';

class CreatePostForm extends StatefulWidget {
  const CreatePostForm({super.key});

  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";
  String _postType = "Discussion";
  List<Club> _selectedClubs = [];
  final List<String> _imageUrls = [];
  final List<TextEditingController> _captionControllers = [];

  late Future<List<Club>> _futureClubs;

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
    _futureClubs = _fetchClubs();
  }

  @override
  void dispose() {
    for (var controller in _captionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<Club>> _fetchClubs() async {
    final response = await http.get(Uri.parse('$_baseUrl/directory/json/'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> leaguesData = data['leagues'];
      final List<Club> allClubs = [];
      for (var leagueJson in leaguesData) {
        final List<dynamic> clubsData = leagueJson['clubs'];
        allClubs.addAll(clubsData.map<Club>((clubJson) => Club.fromJson(clubJson)));
      }
      return allClubs;
    } else {
      throw Exception('Failed to load clubs');
    }
  }

  Future<void> _showAddImageUrlDialog() async {
    if (_imageUrls.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only add a maximum of 3 images.')),
      );
      return;
    }

    final urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/image.png'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Add'),
            onPressed: () {
              //if (urlController.text.isNotEmpty && Uri.tryParse(urlController.text)?.hasAbsolutePath == true) {
                setState(() {
                  _imageUrls.add(urlController.text);
                  _captionControllers.add(TextEditingController());
                });
                Navigator.pop(context);
              //} else {
                //ScaffoldMessenger.of(context).showSnackBar(
                  //const SnackBar(content: Text('Please enter a valid URL.')),
                //);
              //}
            },
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
      _captionControllers[index].dispose();
      _captionControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isAdmin = request.loggedIn ? request.jsonData['is_staff'] ?? false : false;
    // const bool isAdmin = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CREATE NEW POST'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Post Type
              DropdownButtonFormField<String>(
                value: _postType,
                decoration: const InputDecoration(labelText: 'Post Type', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: 'Discussion', child: Text('Discussion')),
                  if (isAdmin)
                    const DropdownMenuItem(value: 'News', child: Text('Official News')),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _postType = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Title
              TextFormField(
                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                onChanged: (String? value) => setState(() => _title = value!),
                validator: (String? value) => (value == null || value.isEmpty) ? "Title cannot be empty!" : null,
              ),
              const SizedBox(height: 16.0),

              // Content
              TextFormField(
                decoration: const InputDecoration(labelText: "Content", border: OutlineInputBorder()),
                maxLines: 10,
                onChanged: (String? value) => setState(() => _content = value!),
                validator: (String? value) => (value == null || value.isEmpty) ? "Content cannot be empty!" : null,
              ),
              const SizedBox(height: 16.0),

              // Club Selector
              FutureBuilder<List<Club>>(
                future: _futureClubs,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final clubs = snapshot.data!;
                  return MultiSelectDialogField(
                    items: clubs.map((c) => MultiSelectItem<Club>(c, c.name)).toList(),
                    title: const Text("Select Clubs"),
                    buttonText: const Text("Associated Clubs"),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
                    onConfirm: (values) {
                      if (values.length > 3) {
                        values.removeRange(3, values.length);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You can select a maximum of 3 clubs.')),
                        );
                      }
                      setState(() {
                        _selectedClubs = values;
                      });
                    },
                    chipDisplay: MultiSelectChipDisplay(items: _selectedClubs.map((c) => MultiSelectItem<Club>(c, c.name)).toList()),
                  );
                },
              ),
              const SizedBox(height: 24.0),

              // Image Manager
              const Text('Images (up to 3)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
              const SizedBox(height: 8.0),
              ..._imageUrls.asMap().entries.map((entry) {
                int idx = entry.key;
                String imageUrl = entry.value;
                final proxiedImageUrl = '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(imageUrl)}';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.network(
                          proxiedImageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(child: Text('Could not load image preview')),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _captionControllers[idx],
                          decoration: const InputDecoration(labelText: 'Optional Caption', border: OutlineInputBorder()),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _removeImage(idx)),
                        )
                      ],
                    ),
                  ),
                );
              }),
              if (_imageUrls.length < 3)
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_link),
                  label: const Text('Add Image URL'),
                  onPressed: _showAddImageUrlDialog,
                ),

              const SizedBox(height: 24.0),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16.0)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final List<String> imageUrls = _imageUrls;
                      final List<String> imageCaptions = _captionControllers.map((controller) => controller.text).toList();

                      // TEST USER
                      // final Map<String, dynamic> requestBody = {
                      //   'title': _title,
                      //   'content': _content,
                      //   'post_type': _postType,
                      //   'clubs': _selectedClubs.map((c) => c.id).toList(),
                      //   'image_urls': imageUrls,
                      //   'image_captions': imageCaptions,
                      // };
                      //
                      // // 2. Use a standard http.post request instead of request.postJson
                      // final response = await http.post(
                      //   Uri.parse("$_baseUrl/forum/api/post/create/flutter/"),
                      //   headers: {"Content-Type": "application/json"},
                      //   body: jsonEncode(requestBody),
                      // );
                      //
                      // // 3. Decode the response from the server.
                      // final responseData = jsonDecode(response.body);


                      final response = await request.postJson(
                          "$_baseUrl/forum/api/post/create/flutter/",
                          jsonEncode(<String, dynamic>{
                            'title': _title,
                            'content': _content,
                            'post_type': _postType,
                            'clubs': _selectedClubs.map((c) => c.id).toList(),
                            'image_urls': imageUrls,
                            'image_captions': imageCaptions,
                          }));

                      if (response['success'] == true) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Post created successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${response['error'] ?? 'An unknown error occurred'}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      // if ((response.statusCode == 200 || response.statusCode == 201) && responseData['success'] == true) {
                      //   Navigator.pop(context);
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     const SnackBar(
                      //       content: Text("Post created successfully!"),
                      //       backgroundColor: Colors.green,
                      //     ),
                      //   );
                      // } else {
                      //   // Display the actual error message from the backend.
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text("Error: ${responseData['error'] ?? 'An unknown error occurred'}"),
                      //       backgroundColor: Colors.red,
                      //     ),
                      //   );
                      // }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unexpected error occurred: $e")));
                    }
                  }
                },
                child: const Text("Submit", style: TextStyle(fontSize: 16.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}