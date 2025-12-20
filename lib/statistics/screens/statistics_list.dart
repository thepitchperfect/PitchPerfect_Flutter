import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/statistics_service.dart';
import '../models/team_statistic.dart';
import '../models/club_ranking.dart';
import 'team_detail.dart';

class StatisticsListPage extends StatefulWidget {
  final String category;
  final String title;

  const StatisticsListPage({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  State<StatisticsListPage> createState() => _StatisticsListPageState();
}

class _StatisticsListPageState extends State<StatisticsListPage> {
  Future<List<dynamic>>? _listFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _listFuture = StatisticsService.fetchSpecificList(request, widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<dynamic>>(
        future: _listFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final data = snapshot.data!;

          if (widget.category == 'rankings') {
            return _buildRankingsList(
              data.map((e) => ClubRanking.fromJson(e)).toList(),
            );
          } else {
            return _buildStatsList(
              data.map((e) => TeamStatistic.fromJson(e)).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatsList(List<TeamStatistic> stats) {
    return ListView.builder(
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        String value = '';
        if (widget.category == 'goals') {
          value = '${stat.scoredPerMatch} goals/match';
        } else if (widget.category == 'possession') {
          value = '${stat.possessionAvg}% possession';
        } else if (widget.category == 'clean_sheets') {
          value = '${stat.cleanSheetsPercentage}% clean sheets';
        }

        return ListTile(
          leading: index < 3
              ? Icon(
                  Icons.emoji_events,
                  color: index == 0
                      ? Colors.amber
                      : (index == 1 ? Colors.grey : Colors.brown),
                )
              : Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          title: Text(stat.clubName),
          subtitle: Text(value),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailPage(clubId: stat.clubId),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRankingsList(List<ClubRanking> rankings) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final rank = rankings[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${rank.rank}')),
          title: Text(rank.clubName),
          subtitle: Text('${rank.points} pts - ${rank.continent}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailPage(clubId: rank.clubId),
              ),
            );
          },
        );
      },
    );
  }
}
