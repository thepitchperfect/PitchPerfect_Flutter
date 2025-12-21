import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pitch_perfect_flutter/forum/widgets/news_card.dart';
import 'package:pitch_perfect_flutter/forum/widgets/discussion_card.dart';
import 'package:pitch_perfect_flutter/forum/screens/create_post_form.dart';
import 'package:pitch_perfect_flutter/clubdirectory/models/club_model.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as forum_model;
import 'package:pitch_perfect_flutter/profile/screens/login.dart';

class ForumHomePage extends StatelessWidget {
  const ForumHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<void> _loadDataFuture;
  List<forum_model.ForumEntry> _allEntries = [];
  List<forum_model.ForumEntry> _filteredNews = [];
  List<forum_model.ForumEntry> _filteredDiscussions = [];
  String _searchQuery = '';
  Club? _selectedClub;
  List<Club> _allClubs = [];
  List<Club> _userFavoriteClubs = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _fetchEntriesAndClubs();
  }

  void _applyFilters() {
    List<forum_model.ForumEntry> filtered = _allEntries;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) => d.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedClub != null) {
      filtered = filtered.where((d) => d.clubs.any((c) => c.id == _selectedClub!.id)).toList();
    }

    setState(() {
      _filteredNews = filtered.where((entry) => entry.postType.toLowerCase() == 'news').toList();
      _filteredDiscussions = filtered.where((entry) => entry.postType.toLowerCase() == 'discussion').toList();
    });
  }

  Future<void> _fetchEntriesAndClubs() async {
    final request = context.read<CookieRequest>();
    final userData = await request.jsonData;
    if (mounted) {
      setState(() {
        _isAdmin = userData['is_staff'] ?? false;

        // --- START OF FLUTTER BYPASS ---
        // For testing purposes, temporarily set _isAdmin to true.
        // This will make the "News" option appear in the CreatePostForm dropdown.
        // REMEMBER to undo this when authentication is implemented!
        // _isAdmin = true;
        // --- END OF FLUTTER BYPASS ---
      });
    }

    // ==== ACTUAL CODE ====
    final response = await request.get('http://localhost:8000/forum/json/');
    final List<forum_model.ForumEntry> entries = [];
    final Set<Club> clubs = {};
    for (var item in response) {
      final entry = forum_model.ForumEntry.fromJson(item);
      entries.add(entry);
      if (entry.clubs.isNotEmpty) {
        clubs.addAll(entry.clubs);
      }
    }

    // Get User favourite clubs
    List<Club> favoriteClubs = [];
    if (request.loggedIn) {
      try {
        final responseFavorites = await request.get('http://localhost:8000/forum/get-favorite-clubs/flutter/');
        if (responseFavorites['status'] == 'success') {
          favoriteClubs = (responseFavorites['clubs'] as List)
              .map((clubJson) => Club.fromJson(clubJson))
              .toList();
        }
      } catch (e) {
        // Handle potential errors if the API call fails
        print("Could not fetch favorite clubs: $e");
      }
    }

    // DELETE THIS LATER === BYPASS USER
    // final response = await http.get(Uri.parse('http://localhost:8000/forum/json/'));
    // final List<dynamic> responseData = json.decode(response.body); // Assuming the response is a direct list
    // final List<forum_model.ForumEntry> entries = [];
    // final Set<Club> clubs = {};
    // for (var item in responseData) {
    //   final entry = forum_model.ForumEntry.fromJson(item);
    //   entries.add(entry);
    //   if (entry.clubs.isNotEmpty) {
    //     clubs.addAll(entry.clubs);
    //   }
    // }
    // === END BYPASS USER ===

    if (mounted) {
      setState(() {
        _allClubs = clubs.toList();
        _userFavoriteClubs = favoriteClubs;
        _allEntries = entries;
        _applyFilters();
      });
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String tempSearchQuery = _searchQuery;
        Club? tempSelectedClub = _selectedClub;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            List<Club> filteredClubs = _isAdmin
                ? _allClubs
                : _userFavoriteClubs;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Options', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: tempSearchQuery,
                    decoration: const InputDecoration(
                      labelText: 'Search by title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      tempSearchQuery = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Club>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by club',
                      border: OutlineInputBorder(),
                    ),
                    value: tempSelectedClub,
                    items: [
                      const DropdownMenuItem<Club>(
                        value: null,
                        child: Text('Your Favourite Clubs'),
                      ),
                      ...filteredClubs.map((Club club) {
                        return DropdownMenuItem<Club>(
                          value: club,
                          child: Text(club.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (Club? newValue) {
                      setModalState(() {
                        tempSelectedClub = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _selectedClub = null;
                            _applyFilters();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = tempSearchQuery;
                            _selectedClub = tempSelectedClub;
                            _applyFilters();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DISCUSSION FORUM',
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1E293B)),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEntriesAndClubs,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OfficialNewsCard(news: _filteredNews),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Latest Discussions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
            FutureBuilder<void>(
              future: _loadDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allEntries.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (_filteredDiscussions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No discussions found.'),
                    )),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return DiscussionCard(post: _filteredDiscussions[index]);
                    },
                    childCount: _filteredDiscussions.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final request = context.read<CookieRequest>();
          if (request.loggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostForm()),
            ).then((_) {
              setState(() {
                _loadDataFuture = _fetchEntriesAndClubs();
              });
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        },
        backgroundColor: const Color(0xFFF97316),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
