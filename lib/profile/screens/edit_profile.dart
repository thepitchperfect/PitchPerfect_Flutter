import 'dart:convert';
import 'dart:io'; // Needed for File and Platform checks
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; // Kept ONLY for MultipartRequest definitions
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pitch_perfect_flutter/profile/models/profile_models.dart';

class EditProfilePage extends StatefulWidget {
  final Profile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String newName;
  late String newEmail;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    newName = widget.user.fullName;
    newEmail = widget.user.email;
  }

  // --- 1. Helper for Dynamic URL (Crucial for Emulator) ---
  String get _baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://localhost:8000";
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Helper logic for image display
    String? currentPicUrl = widget.user.profpict;
    if (currentPicUrl != null && !currentPicUrl.startsWith('http')) {
      currentPicUrl = "$_baseUrl$currentPicUrl"; // Use dynamic base URL
    }

    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(File(_imageFile!.path));
    } else if (currentPicUrl != null && currentPicUrl.isNotEmpty) {
      imageProvider = NetworkImage(currentPicUrl);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Profile Picture ===
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFE8800),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFE8800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    "Change Profile Picture",
                    style: TextStyle(color: Color(0xFFFE8800)),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // === Username ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.user.username,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    filled: true,
                    fillColor: Color(0xFFF3F4F6),
                  ),
                ),
              ),

              // === Full Name ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: newName,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (val) => setState(() => newName = val),
                  validator: (val) => val == null || val.isEmpty
                      ? "Name cannot be empty"
                      : null,
                ),
              ),

              // === Email ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: newEmail,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    labelText: "Email Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (val) => setState(() => newEmail = val),
                  validator: (val) => val == null || val.isEmpty
                      ? "Email cannot be empty"
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xFFFE8800),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                try {
                                  // 0. GET THE REQUEST OBJECT (Ensure this exists)
                                  // Assuming you are using Provider:
                                  // final request = context.read<CookieRequest>();

                                  // 1. Prepare URL
                                  final url = Uri.parse(
                                    "$_baseUrl/auth/profile/edit/",
                                  );

                                  // 2. Prepare Request
                                  final multipartRequest =
                                      http.MultipartRequest('POST', url);

                                  // Add Fields
                                  multipartRequest.fields['full_name'] =
                                      newName;
                                  multipartRequest.fields['email'] = newEmail;

                                  // Add File (if present)
                                  if (_imageFile != null) {
                                    final Uint8List imageBytes =
                                        await _imageFile!.readAsBytes();
                                    final multipartFile =
                                        http.MultipartFile.fromBytes(
                                          'profpict', // Make sure this matches Django field name exactly
                                          imageBytes,
                                          filename: _imageFile!.name,
                                        );
                                    multipartRequest.files.add(multipartFile);
                                  }

                                  // 3. FIX AUTHENTICATION & HEADERS

                                  // A. Copy existing headers
                                  Map<String, String> headers = Map.from(
                                    request.headers,
                                  );

                                  // B. Safe "Content-Type" removal (handles 'content-type' and 'Content-Type')
                                  headers.removeWhere(
                                    (key, value) =>
                                        key.toLowerCase() == "content-type",
                                  );

                                  // C. MANUALLY INSERT COOKIES
                                  // This bridges the gap between pbp_django_auth and http.MultipartRequest
                                  if (request.cookies.isNotEmpty) {
                                    // Create a raw Cookie string (e.g., "sessionid=xyz; csrftoken=abc")
                                    String cookieHeader = request
                                        .cookies
                                        .entries
                                        .map((e) => "${e.key}=${e.value}")
                                        .join("; ");
                                    headers['Cookie'] = cookieHeader;
                                  }

                                  multipartRequest.headers.addAll(headers);

                                  // 4. Send
                                  final streamedResponse =
                                      await multipartRequest.send();
                                  final response = await http
                                      .Response.fromStream(streamedResponse);

                                  if (context.mounted) {
                                    setState(() => _isLoading = false);

                                    if (response.statusCode == 200) {
                                      Navigator.pop(context, true);
                                    } else {
                                      // ... (Error handling logic remains the same) ...
                                      String errMessage =
                                          "Update failed: ${response.statusCode}";
                                      // ...
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(errMessage),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
