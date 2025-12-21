import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/matchpredictionmodel.dart';
import '../widgets/matchprediction_card.dart';
import '../../clubdirectory/models/club_model.dart';

class MatchListScreen extends StatefulWidget {
  final String leagueName; // 🔥 STABLE IDENTIFIER
  final String filterType;
  final String searchQuery;

  const MatchListScreen({
    super.key,
    required this.leagueName,
    required this.filterType,
    required this.searchQuery,
  });

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  late Future<List<Matchprediction>> _futureMatches;
  late Future<Map<String, Club>> _futureClubMap;

  @override
  void initState() {
    super.initState();
    _futureMatches = fetchMatches();
    _futureClubMap = fetchClubMap();
  }

  @override
  void didUpdateWidget(covariant MatchListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.leagueName != widget.leagueName ||
        oldWidget.filterType != widget.filterType ||
        oldWidget.searchQuery != widget.searchQuery) {
      setState(() {
        _futureMatches = fetchMatches();
      });
    }
  }

  // ==============================
  // 🔵 FETCH MATCHES (STABLE)
  // ==============================
  Future<List<Matchprediction>> fetchMatches() async {
    final baseUrl = Platform.isAndroid
        ? "http://10.0.2.2:8000"
        : "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";

    final uri = Uri.parse("$baseUrl/predictions/json/").replace(
      queryParameters: {
        if (widget.searchQuery.isNotEmpty) 'search': widget.searchQuery,
        if (widget.filterType != 'all') 'filter': widget.filterType,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to load matches (${response.statusCode})");
    }

    List<Matchprediction> matches =
        matchpredictionFromJson(response.body);

    // ✅ STABLE LEAGUE FILTER (NAME-BASED)
    if (widget.leagueName.isNotEmpty) {
      matches = matches.where((m) {
        return m.league.name == widget.leagueName;
      }).toList();
    }

    return matches;
  }

  String get _baseUrl {
    if (kIsWeb) {
      return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "https://arisa-raezzura-pitchperfect.pbp.cs.ui.ac.id";
  }
  
  // ==============================
  // 🔵 FETCH CLUB DIRECTORY
  // ==============================
  Future<Map<String, Club>> fetchClubMap() async {
    final response =
        await http.get(Uri.parse("$_baseUrl/directory/json/"));

    if (response.statusCode != 200) {
      throw Exception("Failed to load club directory");
    }

    final decoded = json.decode(response.body);

    List leagueList;

    if (decoded is List) {
      leagueList = decoded;
    } else if (decoded is Map && decoded['leagues'] is List) {
      leagueList = decoded['leagues'];
    } else {
      throw Exception("Unsupported club directory JSON structure");
    }

    final Map<String, Club> clubMap = {};

    for (final leagueJson in leagueList) {
      final league = League.fromJson(leagueJson);
      for (final club in league.clubs) {
        clubMap[club.id] = club;
      }
    }

    return clubMap;
  }

  // ==============================
  // 🔵 UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Club>>(
      future: _futureClubMap,
      builder: (context, clubSnapshot) {
        if (clubSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (clubSnapshot.hasError) {
          return Center(
            child: Text(
              "Error loading clubs\n${clubSnapshot.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final clubMap = clubSnapshot.data!;

        return FutureBuilder<List<Matchprediction>>(
          future: _futureMatches,
          builder: (context, matchSnapshot) {
            if (matchSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (matchSnapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading matches\n${matchSnapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final matches = matchSnapshot.data!;

            if (matches.isEmpty) {
              return const Center(child: Text("No matches available"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return MatchCard(
                  match: matches[index],
                  clubMap: clubMap,
                );
              },
            );
          },
        );
      },
    );
  }
}
