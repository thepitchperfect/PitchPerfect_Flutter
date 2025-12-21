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
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
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
                                  final request = context.read<CookieRequest>();

                                  final url = Uri.parse(
                                    "$_baseUrl/auth/profile/edit/",
                                  );

                                  // 1. Create Request
                                  final multipartRequest =
                                      http.MultipartRequest('POST', url);

                                  // 2. Add Fields
                                  multipartRequest.fields['full_name'] =
                                      newName;
                                  multipartRequest.fields['email'] = newEmail;

                                  // 3. Add File
                                  if (_imageFile != null) {
                                    final Uint8List imageBytes =
                                        await _imageFile!.readAsBytes();
                                    final multipartFile =
                                        http.MultipartFile.fromBytes(
                                          'profpict',
                                          imageBytes,
                                          filename: _imageFile!.name,
                                        );
                                    multipartRequest.files.add(multipartFile);
                                  }

                                  // 4. AUTHENTICATION (The Fix)
                                  // We prefer the headers from the provider as they are pre-formatted
                                  Map<String, String> headers = Map.from(
                                    request.headers,
                                  );

                                  // If 'Cookie' header is missing but we have cookies in the map, construct it manually
                                  if (headers['cookie'] == null &&
                                      request.cookies.isNotEmpty) {
                                    String cookieHeader = request
                                        .cookies
                                        .entries
                                        .map((e) => "${e.key}=${e.value}")
                                        .join("; ");
                                    headers['cookie'] = cookieHeader;
                                  }

                                  // Remove content-type so MultipartRequest can set its own boundary
                                  headers.removeWhere(
                                    (key, value) =>
                                        key.toLowerCase() == "content-type",
                                  );

                                  multipartRequest.headers.addAll(headers);

                                  // DEBUG: Print headers to ensure 'cookie' (with sessionid) is present
                                  print(
                                    "Sending Headers: ${multipartRequest.headers}",
                                  );

                                  // 5. Send
                                  final streamedResponse =
                                      await multipartRequest.send();
                                  final response = await http
                                      .Response.fromStream(streamedResponse);

                                  if (context.mounted) {
                                    setState(() => _isLoading = false);

                                    if (response.statusCode == 200) {
                                      // Success!
                                      Navigator.pop(context, true);
                                    } else if (response.statusCode == 302) {
                                      // HANDLE 302: This specifically catches the Login Redirect
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Session expired. Please login again.",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      // Optional: Navigate user back to login page here
                                    } else {
                                      print("Server Error: ${response.body}");
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error: ${response.statusCode}. Check logs.",
                                          ),
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
