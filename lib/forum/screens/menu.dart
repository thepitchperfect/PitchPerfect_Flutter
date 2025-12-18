import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as forum_model;
import 'package:pitch_perfect_flutter/forum/widgets/news_card.dart';
import 'package:pitch_perfect_flutter/forum/widgets/discussion_card.dart';

class ForumHomePage extends StatelessWidget {
  const ForumHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<forum_model.ForumEntry>> _futureDiscussions;

  @override
  void initState() {
    super.initState();
    _futureDiscussions = _fetchDiscussions();
  }

  Future<List<forum_model.ForumEntry>> _fetchDiscussions() async {
    final response = await http.get(Uri.parse('http://localhost:8000/forum/json/'));
    if (response.statusCode == 200) {
      final List<forum_model.ForumEntry> entries = forum_model.forumEntryFromJson(response.body);
      return entries.where((entry) => entry.postType.toLowerCase() == 'discussion').toList();
    } else {
      throw Exception('Failed to load discussions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forum Discussion',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _futureDiscussions = _fetchDiscussions();
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const OfficialNewsCard(),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Discussions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<forum_model.ForumEntry>>(
              future: _futureDiscussions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No discussions found.')),
                  );
                }

                final discussions = snapshot.data!;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return DiscussionCard(post: discussions[index]);
                    },
                    childCount: discussions.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan title dan content.

  final String title;  // Judul kartu.
  final String content;  // Isi kartu.

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Membuat kotak kartu dengan bayangan dibawahnya.
      elevation: 2.0,
      child: Container(
        // Mengatur ukuran dan jarak di dalam kartu.
        width: MediaQuery.of(context).size.width / 3.5, // menyesuaikan dengan lebar device yang digunakan.
        padding: const EdgeInsets.all(16.0),
        // Menyusun title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon);
}
