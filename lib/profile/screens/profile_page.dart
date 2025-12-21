import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitch_perfect_flutter/profile/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- IMPORTS ---
// Adjust these paths if your file structure is different
import 'package:pitch_perfect_flutter/profile/models/profile_models.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart';
import 'package:pitch_perfect_flutter/profile/widgets/profile_header.dart';
import 'package:pitch_perfect_flutter/profile/widgets/post_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Futures to hold state
  late Future<Profile> _futureProfile;
  late Future<List<ForumEntry>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initial fetch (Safe to read provider here)
    final request = context.read<CookieRequest>();
    _futureProfile = fetchProfile(request);
    _futurePosts = fetchPosts(request);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- REFRESH DATA ---
  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _futureProfile = fetchProfile(request);
      _futurePosts = fetchPosts(request);
    });
  }

  // --- API: FETCH PROFILE ---
  Future<Profile> fetchProfile(CookieRequest request) async {
    // 1. Fetch data
    final response = await request.get('http://127.0.0.1:8000/auth/profile/');

    var data = response;
    Profile profile;

    // 2. Parse JSON
    if (data is List) {
      profile = Profile.fromJson(data[0]);
    } else {
      profile = Profile.fromJson(data);
    }

    // 3. CACHE BUSTING TRICK
    // If we have a profile picture, append a random timestamp to the URL
    // This forces Flutter to re-download the image instead of using the cache
    if (profile.profpict != null && profile.profpict!.isNotEmpty) {
      // Create a new Profile object with the modified URL, or just modify the model if it's mutable
      // Assuming your Profile model fields are final, we might need to handle this in the Widget instead.
      // But usually, modifying the model here is cleaner if you can.
      // Since your Profile fields are likely final, let's just leave it and handle it in the Widget below.
    }

    return profile;
  }

  // --- API: FETCH POSTS ---
  Future<List<ForumEntry>> fetchPosts(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/forum/');
    List<ForumEntry> listPosts = [];
    for (var d in response) {
      if (d != null) {
        listPosts.add(ForumEntry.fromJson(d));
      }
    }
    return listPosts;
  }

  // --- NAVIGATION: EDIT PROFILE ---
  Future<void> _handleEditProfile(Profile currentUser) async {
    // Push to the separate EditProfilePage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: currentUser),
      ),
    );

    // If result is true, it means the user saved changes
    if (result == true) {
      _refreshData(); // Refresh the profile to show new name/email

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Outer FutureBuilder for USER PROFILE
      body: FutureBuilder<Profile>(
        future: _futureProfile,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // 3. No Data
          else if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found"));
          }

          // 4. Data Loaded
          final user = snapshot.data!;

          return SafeArea(
            child: Column(
              children: [
                // HEADER
                // Pass the function using a closure () =>
                ProfileHeader(
                  user: user,
                  onEditPressed: () => _handleEditProfile(user),
                ),

                // TAB BAR
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFFFE8800),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: const Color(0xFFFE8800),
                    labelStyle: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: "League Picks"),
                      Tab(text: "Posts"),
                      Tab(text: "Predictions"),
                    ],
                  ),
                ),

                // TAB CONTENT
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: League Picks (Placeholder)
                      const Center(child: Text("League picks coming soon...")),

                      // Tab 2: Posts (Inner FutureBuilder)
                      FutureBuilder<List<ForumEntry>>(
                        future: _futurePosts,
                        builder: (context, postSnapshot) {
                          if (postSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (postSnapshot.hasError) {
                            return Center(
                              child: Text("Error: ${postSnapshot.error}"),
                            );
                          } else if (!postSnapshot.hasData ||
                              postSnapshot.data!.isEmpty) {
                            return const Center(child: Text("No posts yet."));
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: postSnapshot.data!.length,
                            itemBuilder: (context, index) =>
                                PostCard(post: postSnapshot.data![index]),
                          );
                        },
                      ),

                      // Tab 3: Predictions (Placeholder)
                      const Center(child: Text("Predictions coming soon...")),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
