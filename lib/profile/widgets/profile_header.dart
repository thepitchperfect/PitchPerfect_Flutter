import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/profile/screens/login.dart';
import 'package:pitch_perfect_flutter/profile/models/profile_models.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:pbp_django_auth/pbp_django_auth.dart'; // 2. Import PBP Django Auth

class ProfileHeader extends StatelessWidget {
  final Profile user;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

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
    // 4. Get the request object from Provider
    final request = context.watch<CookieRequest>();

    ImageProvider? imageProvider;

    if (user.profpict != null && user.profpict!.isNotEmpty) {
      String url = user.profpict!;
      if (!url.startsWith("http")) {
        if (url.startsWith("/")) {
          url = url.substring(1);
        }
        url = "$_baseUrl/$url";
      }
      imageProvider = NetworkImage(url);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // BUTTONS ROW (Edit Left, Logout Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // EDIT BUTTON
              ElevatedButton(
                onPressed: onEditPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE8800),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // LOGOUT BUTTON (Icon Only)
              IconButton(
                icon: const Icon(Icons.logout),
                color: Color(0xFFFE8800), // Red color for logout action
                tooltip: "Logout",
                onPressed: () async {
                  // Use _baseUrl to ensure it works on Android Emulator too
                  final response = await request.logout(
                    "$_baseUrl/auth/logout/",
                  );

                  String message = response["message"];

                  if (context.mounted) {
                    if (response['status']) {
                      String uname = response["username"];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$message See you again, $uname."),
                        ),
                      );

                      // Navigate back to Login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          // PROFILE PICTURE
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFE8800), width: 4),
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,

              // 1. Pass the provider (can be null)
              backgroundImage: imageProvider,

              // 2. THE FIX: Only provide the error listener if the provider is NOT null
              onBackgroundImageError: imageProvider != null
                  ? (exception, stackTrace) {
                      debugPrint("Image Load Error: $exception");
                    }
                  : null,

              // 3. Fallback child
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 15),

          // USER INFO
          Text(
            user.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
