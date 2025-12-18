import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:pitch_perfect_flutter/forum/widgets/news_card.dart';
import 'package:pitch_perfect_flutter/forum/widgets/discussion_card.dart';
import 'package:pitch_perfect_flutter/forum/screens/create_post_form.dart';
// import 'package:pitch_perfect_flutter/authentication/screens/login.dart';
import 'package:pitch_perfect_flutter/forum/models/forum_entry.dart' as forum_model;

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
  late Future<List<forum_model.ForumEntry>> _futureDiscussions;

  @override
  void initState() {
    super.initState();
    _futureDiscussions = _fetchDiscussions(context);
  }

  Future<List<forum_model.ForumEntry>> _fetchDiscussions(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/forum/json/');
    final List<forum_model.ForumEntry> entries = [];
    for (var item in response) {
      entries.add(forum_model.ForumEntry.fromJson(item));
    }
    return entries.where((entry) => entry.postType.toLowerCase() == 'discussion').toList();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

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
            _futureDiscussions = _fetchDiscussions(context);
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    const SizedBox(height: 8.0),
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
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No discussions found.'),
                    )),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // if (request.loggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostForm()),
            ).then((_) {
              // Refresh the discussions list after a new post is created
              setState(() {
                _futureDiscussions = _fetchDiscussions(context);
              });
            });
          // } else {
            // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) => const ForumHomePage()),/// change this
            // );
          },
        // },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
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
