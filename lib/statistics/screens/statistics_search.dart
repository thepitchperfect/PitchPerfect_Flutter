import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/statistics/models/team_statistic.dart';
import 'package:pitch_perfect_flutter/statistics/screens/team_detail.dart';

class StatisticsSearchDelegate extends SearchDelegate {
  final List<TeamStatistic> allClubs;

  StatisticsSearchDelegate(this.allClubs);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allClubs.where((club) =>
        club.clubName.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final club = results[index];
        return ListTile(
          leading: club.logoUrl != null
              ? Image.network(club.logoUrl!, width: 40, height: 40, errorBuilder: (_, __, ___) => const Icon(Icons.shield))
              : const Icon(Icons.shield),
          title: Text(club.clubName),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailPage(clubId: club.clubId),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allClubs.where((club) =>
        club.clubName.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final club = suggestions[index];
        return ListTile(
          leading: club.logoUrl != null
              ? Image.network(club.logoUrl!, width: 30, height: 30, errorBuilder: (_, __, ___) => const Icon(Icons.shield))
              : const Icon(Icons.shield),
          title: Text(club.clubName),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailPage(clubId: club.clubId),
              ),
            );
          },
        );
      },
    );
  }
}
