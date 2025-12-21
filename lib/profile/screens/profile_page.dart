import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitch_perfect_flutter/profile/widgets/club_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:pitch_perfect_flutter/profile/models/profile_models.dart';
import 'package:pitch_perfect_flutter/profile/models/activity_models.dart';
import 'package:pitch_perfect_flutter/profile/widgets/profile_header.dart';
import 'package:pitch_perfect_flutter/profile/screens/edit_profile.dart';
import 'package:pitch_perfect_flutter/profile/widgets/post_card.dart';
import 'package:pitch_perfect_flutter/profile/widgets/prediction_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }

  Future<Profile>? _futureProfile;
  Future<UserActivity>? _futureActivity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _futureProfile = fetchProfile(request);
      _futureActivity = fetchUserActivity(request);
    });
  }

  Future<Profile> fetchProfile(CookieRequest request) async {
    final response = await request.get('$_baseUrl/auth/profile/');
    if (response is List) {
      return Profile.fromJson(response[0]);
    } else {
      return Profile.fromJson(response);
    }
  }

  Future<UserActivity> fetchUserActivity(CookieRequest request) async {
    final response = await request.get('$_baseUrl/api/user-activity/');
    return UserActivity.fromJson(response);
  }

  Future<void> _handleEditProfile(Profile currentUser) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: currentUser),
      ),
    );

    if (result == true) {
      _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated!"),
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
      appBar: AppBar(
        title: const Text(
          'USER PROFILE',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _futureProfile == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Profile>(
              future: _futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                else if (!snapshot.hasData) {
                  return const Center(child: Text("No profile data found"));
                }

                final user = snapshot.data!;

                return SafeArea(
                  child: Column(
                    children: [
                      ProfileHeader(
                        user: user,
                        onEditPressed: () => _handleEditProfile(user),
                      ),

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
                          unselectedLabelStyle: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          tabs: const [
                            Tab(text: "League Picks"),
                            Tab(text: "Posts"),
                            Tab(text: "Predictions"),
                          ],
                        ),
                      ),

                      Expanded(
                        child: _futureActivity == null
                            ? const Center(child: CircularProgressIndicator())
                            : FutureBuilder<UserActivity>(
                                future: _futureActivity,
                                builder: (context, actSnapshot) {
                                  if (actSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (actSnapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "Error: ${actSnapshot.error}",
                                      ),
                                    );
                                  } else if (!actSnapshot.hasData) {
                                    return const Center(
                                      child: Text("No activity data."),
                                    );
                                  }

                                  final activity = actSnapshot.data!;

                                  return TabBarView(
                                    controller: _tabController,
                                    children: [
                                      activity.leaguePicks.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "No clubs picked yet.",
                                              ),
                                            )
                                          : GridView.builder(
                                              padding: const EdgeInsets.all(16),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        2,
                                                    childAspectRatio:
                                                        1.0,
                                                    crossAxisSpacing: 16,
                                                    mainAxisSpacing: 16,
                                                  ),
                                              itemCount:
                                                  activity.leaguePicks.length,
                                              itemBuilder: (context, index) {
                                                return ClubGridItem(
                                                  club: activity
                                                      .leaguePicks[index],
                                                );
                                              },
                                            ),

                                      activity.userPosts.isEmpty
                                          ? const Center(
                                              child: Text("No posts yet."),
                                            )
                                          : ListView.builder(
                                              padding: const EdgeInsets.all(16),
                                              itemCount:
                                                  activity.userPosts.length,
                                              itemBuilder: (context, index) {
                                                return PostCard(
                                                  post:
                                                      activity.userPosts[index],
                                                );
                                              },
                                            ),

                                      activity.userPredictions.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "No predictions made.",
                                              ),
                                            )
                                          : ListView.builder(
                                              padding: const EdgeInsets.all(16),
                                              itemCount: activity
                                                  .userPredictions
                                                  .length,
                                              itemBuilder: (context, index) {
                                                return PredictionCard(
                                                  prediction: activity
                                                      .userPredictions[index],
                                                );
                                              },
                                            ),
                                    ],
                                  );
                                },
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
