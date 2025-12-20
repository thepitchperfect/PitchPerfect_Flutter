import 'package:flutter/material.dart';
import '../models/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  final Profile user;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    // ----------------------------------------------------------------------
    // STEP 1: Define your Base URL
    // Use 'http://10.0.2.2:8000' for Android Emulator
    // Use 'http://127.0.0.1:8000' for iOS Simulator or Web
    // ----------------------------------------------------------------------
    const String baseUrl = "http://127.0.0.1:8000";

    // ----------------------------------------------------------------------
    // STEP 2: Logic to fix the image URL
    // ----------------------------------------------------------------------
    ImageProvider? imageProvider;

    if (user.profpict != null && user.profpict!.isNotEmpty) {
      String url = user.profpict!;

      // Check if the URL is relative (doesn't start with http)
      if (!url.startsWith("http")) {
        // If the URL has a leading slash, remove it to avoid double slashes
        // (though browsers usually handle double slashes, it's cleaner to remove)
        if (url.startsWith("/")) {
          url = url.substring(1);
        }
        // Combine base + relative path
        // Final result looks like: http://127.0.0.1:8000/media/profile_pics/...
        url = "$baseUrl/$url";
      }
      
      imageProvider = NetworkImage(url);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // Edit Button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
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
          ),
          const SizedBox(height: 10),

          // Profile Picture Circle
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
              // Only load the image if we successfully created the provider
              backgroundImage: imageProvider,
              // If imageProvider is null (failed or empty), show the Icon
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
              onBackgroundImageError: (exception, stackTrace) {
                // This helps you debug if the URL is still wrong in the console
                debugPrint("Image Load Error: $exception");
              },
            ),
          ),
          const SizedBox(height: 15),

          // User Name & Email
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
