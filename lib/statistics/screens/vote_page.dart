import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/statistics_service.dart';
import '../models/vote_models.dart';

class VotePage extends StatefulWidget {
  const VotePage({super.key});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  Future<Map<String, dynamic>>? _voteDataFuture;
  List<SimpleClub> _clubs = [];
  String? _selectedClubId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _loadClubs();
  }

  void _refreshData() {
    final request = context.read<CookieRequest>();
    setState(() {
      _voteDataFuture = StatisticsService.fetchVoteResults(request);
    });
  }

  Future<void> _loadClubs() async {
    final request = context.read<CookieRequest>();
    final clubs = await StatisticsService.fetchAllClubs(request);
    setState(() {
      _clubs = clubs;
    });
  }

  Future<void> _submitVote() async {
    if (_selectedClubId == null) return;

    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await StatisticsService.voteClub(
        request,
        _selectedClubId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response['message'])));
        if (response['status'] == 'success') {
          _refreshData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vote Club of the Season')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cast your vote for the best club of the 2025/26 season!",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Voting Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Select a Club",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedClubId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _clubs.map((club) {
                        return DropdownMenuItem(
                          value: club.id,
                          child: Text(club.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedClubId = val),
                      hint: const Text("Choose a club..."),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading || _selectedClubId == null
                          ? null
                          : _submitVote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Submit Vote"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Live Results",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Results List
            FutureBuilder<Map<String, dynamic>>(
              future: _voteDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final data = snapshot.data!;
                final results = (data['results'] as List)
                    .map((e) => VoteResult.fromJson(e))
                    .toList();
                final userVote = data['user_vote'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userVote != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Chip(
                          avatar: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          label: Text('You voted for: $userVote'),
                        ),
                      ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return Column(
                          children: [
                            ListTile(
                              leading: Text(
                                "#${index + 1}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              title: Text(result.clubName),
                              trailing: Text(
                                "${result.voteCount} votes",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
