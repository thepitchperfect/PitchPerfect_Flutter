import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/matchpredictionmodel.dart';
import '../../clubdirectory/models/club_model.dart';

class MatchPredictionDetail extends StatefulWidget {
  final Matchprediction match;

  const MatchPredictionDetail({
    super.key,
    required this.match,
  });

  @override
  State<MatchPredictionDetail> createState() =>
      _MatchPredictionDetailState();
}

class _MatchPredictionDetailState extends State<MatchPredictionDetail> {
  late Future<Map<String, Club>> _futureClubMap;

  String? _userPrediction;

  @override
  void initState() {
    super.initState();
    _futureClubMap = fetchClubMap();
    _userPrediction = widget.match.userVote;
  }

  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }

  Future<Map<String, Club>> fetchClubMap() async {
    final response =
        await http.get(Uri.parse("$_baseUrl/directory/json/"));

    if (response.statusCode != 200) {
      throw Exception("Failed to load club directory");
    }

    final decoded = json.decode(response.body);
    List leagues;

    if (decoded is Map && decoded['leagues'] is List) {
      leagues = decoded['leagues'];
    } else if (decoded is List) {
      leagues = decoded;
    } else {
      throw Exception("Invalid club JSON");
    }

    final Map<String, Club> clubMap = {};
    for (final leagueJson in leagues) {
      final league = League.fromJson(leagueJson);
      for (final club in league.clubs) {
        clubMap[club.id] = club;
      }
    }
    return clubMap;
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final votes = match.voteSummary;

    return FutureBuilder<Map<String, Club>>(
      future: _futureClubMap,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "Error loading clubs\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final clubMap = snapshot.data!;
        final homeClub = clubMap[match.homeTeam.id];
        final awayClub = clubMap[match.awayTeam.id];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text("Match Predictions"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _teamHeader(homeClub)),
                      Column(
                        children: [
                          const Text(
                            "VS",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDate(match.matchDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _statusBadge(match.status),
                        ],
                      ),
                      Expanded(child: _teamHeader(awayClub)),
                    ],
                  ),

                  const Divider(height: 40),

                  const Text(
                    "Cast Your Prediction",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _voteButton(
                          context,
                          label: "${homeClub?.name ?? 'Home'} Win",
                          color: Colors.green,
                          prediction: "home_win",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _voteButton(
                          context,
                          label: "Draw",
                          color: Colors.amber,
                          prediction: "draw",
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _voteButton(
                          context,
                          label: "${awayClub?.name ?? 'Away'} Win",
                          color: Colors.blue,
                          prediction: "away_win",
                        ),
                      ),
                    ],
                  ),

                  if (_userPrediction != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check_circle,
                                  color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                "You have already voted for this match!",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Your prediction: ${_userPrediction!.replaceAll('_', ' ').toUpperCase()}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.amber),
                                  onPressed: () {
                                    setState(() {
                                      _userPrediction = null;
                                    });
                                  },
                                  child:
                                      const Text("Edit Vote"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.red),
                                  onPressed: _deleteVote,
                                  child:
                                      const Text("Delete Vote"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 40),

                  _resultBar(
                    label: "${homeClub?.name ?? 'Home'} Win",
                    percent: votes.homeWin,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  _resultBar(
                    label: "Draw",
                    percent: votes.draw,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  _resultBar(
                    label: "${awayClub?.name ?? 'Away'} Win",
                    percent: votes.awayWin,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Total votes: ${match.totalVotes} fans",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Back to Matches",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _teamHeader(Club? club) {
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              club?.logoUrl != null
                  ? NetworkImage(club!.logoUrl!)
                  : null,
          child: club?.logoUrl == null
              ? const Icon(Icons.shield, size: 36)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          club?.name ?? "Unknown",
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _resultBar({
    required String label,
    required double percent,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600)),
            Text("${percent.toStringAsFixed(1)}%",
                style:
                    const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 14,
            backgroundColor: Colors.grey.shade200,
            valueColor:
                AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} "
        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Widget _voteButton(
    BuildContext context, {
    required String label,
    required Color color,
    required String prediction,
  }) {
    final bool hasVoted = _userPrediction != null;
    final bool isSelected = _userPrediction == prediction;

    return ElevatedButton(
      onPressed: hasVoted
          ? null
          : () async {
              final confirmed =
                  await _confirmVote(context, label);
              if (confirmed) {
                await _submitVote(context, prediction);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? color.withOpacity(0.9)
            : hasVoted
                ? Colors.grey.shade400
                : color,
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 10),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<bool> _confirmVote(
      BuildContext context, String label) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Confirm Your Vote"),
            content:
                Text('Are you sure you want to vote for "$label"?'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text("Confirm"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submitVote(
    BuildContext context,
    String prediction,
  ) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      "$_baseUrl/predictions/vote/api/${widget.match.id}/",
      {"prediction": prediction},
    );

    setState(() {
      _userPrediction = prediction;
      widget.match.totalVotes = response["total_votes"];
      widget.match.voteSummary =
          VoteSummary.fromJson(response["vote_summary"]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Vote submitted successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

Future<void> _deleteVote() async {
  final request = context.read<CookieRequest>();

  final response = await request.post(
    "$_baseUrl/predictions/delete-vote/api/${widget.match.id}/",
    {},
  );

  setState(() {
    _userPrediction = null;
    widget.match.totalVotes = response["total_votes"];
    widget.match.voteSummary =
        VoteSummary.fromJson(response["vote_summary"]);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Vote deleted successfully"),
      backgroundColor: Colors.red,
    ),
  );
}
}
