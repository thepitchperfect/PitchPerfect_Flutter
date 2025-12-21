import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/statistics_service.dart';
import '../models/team_statistic.dart';
import '../models/club_ranking.dart';
import 'statistics_list.dart';
import 'vote_page.dart';
import 'team_detail.dart';
import 'statistics_search.dart';

class StatisticsHomePage extends StatefulWidget {
  const StatisticsHomePage({super.key});

  @override
  State<StatisticsHomePage> createState() => _StatisticsHomePageState();
}

class _StatisticsHomePageState extends State<StatisticsHomePage> {
  Future<Map<String, dynamic>>? _dataFuture;
  List<TeamStatistic> _allClubsForSearch = [];

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _dataFuture = StatisticsService.fetchGeneralStats(request);
    _loadAllClubs(request);
  }

  Future<void> _loadAllClubs(CookieRequest request) async {
    // We can re-use fetchGeneralStats if it has all clubs, 
    // or create a new method to fetch just names/ids for search.
    // For now, let's assume we can get a list of clubs from somewhere or 
    // maybe we just use the top lists as a starting point.
    // To do it properly, we should add an endpoint or method to get all clubs.

    // Assuming fetchAllClubs returns SimpleClub, we might need to map it to TeamStatistic
    // or just change SearchDelegate to use SimpleClub.
    // Let's use fetchAllClubs from StatisticsService which returns SimpleClub
    try {
      final simpleClubs = await StatisticsService.fetchAllClubs(request);
      // Map SimpleClub to TeamStatistic (minimal fields needed for search)
      setState(() {
        _allClubsForSearch = simpleClubs.map((sc) => TeamStatistic(
          clubId: sc.id,
          clubName: sc.name,
          logoUrl: sc.logoUrl,
          // Dummy values for required fields
          season: '',
          matchesPlayed: 0,
          wins: 0,
          draws: 0,
          losses: 0,
          winPercentage: 0,
          scoredPerMatch: 0,
          concededPerMatch: 0,
          avgMatchGoals: 0,
          cleanSheetsPercentage: 0,
          failedToScorePercentage: 0,
          possessionAvg: 0,
          shotsTakenPerMatch: 0,
          shotsConversionRate: 0,
          foulsCommittedPerMatch: 0,
          fouledAgainstPerMatch: 0,
          penaltiesWon: '',
          penaltiesConceded: '',
          goalKicksPerMatch: 0,
          throwInsPerMatch: 0,
          freeKicksPerMatch: 0,
        )).toList();
      });
    } catch (e) {
      print("Error loading clubs for search: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Football Statistics Hub',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StatisticsSearchDelegate(_allClubsForSearch),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final topGoals = (data['top_goals'] as List)
              .map((e) => TeamStatistic.fromJson(e))
              .toList();
          final topPossession = (data['top_possession'] as List)
              .map((e) => TeamStatistic.fromJson(e))
              .toList();
          final topCleanSheets = (data['top_clean_sheets'] as List)
              .map((e) => TeamStatistic.fromJson(e))
              .toList();
          final rankings = (data['rankings'] as List)
              .map((e) => ClubRanking.fromJson(e))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildActionButtons(context),
                const SizedBox(height: 24),

                _buildSectionCard(
                  context,
                  'Top Goals (Club Stats)',
                  'goals',
                  _buildGoalsTable(topGoals),
                ),

                const SizedBox(height: 20),
                _buildSectionCard(
                  context,
                  'Top Possession Leaders',
                  'possession',
                  _buildPossessionTable(topPossession),
                ),

                const SizedBox(height: 20),
                _buildSectionCard(
                  context,
                  'Top Clean Sheets',
                  'clean_sheets',
                  _buildCleanSheetsTable(topCleanSheets),
                ),

                const SizedBox(height: 20),
                _buildSectionCard(
                  context,
                  'FIFA Club World Rankings',
                  'rankings',
                  _buildRankingsTable(rankings),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Text(
            "Track, compare, and analyze the best players and clubs in football",
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VotePage()),
            );
          },
          icon: const Icon(Icons.how_to_vote),
          label: const Text('Vote Club of Season'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF97316),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String category,
    Widget content,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(0), child: content),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StatisticsListPage(category: category, title: title),
                    ),
                  );
                },
                child: Text('View All'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTable(List<TeamStatistic> stats) {
    return _buildDataTable(
      columns: ['Rank', 'Club', 'Goals/Match'],
      rows: stats
          .map(
            (stat) => [
              _buildClubCell(stat),
              Text(
                stat.scoredPerMatch.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          )
          .toList(),
    );
  }

  Widget _buildPossessionTable(List<TeamStatistic> stats) {
    return _buildDataTable(
      columns: ['Rank', 'Club', 'Possession'],
      rows: stats
          .map(
            (stat) => [
              _buildClubCell(stat),
              Text(
                "${stat.possessionAvg}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          )
          .toList(),
    );
  }

  Widget _buildCleanSheetsTable(List<TeamStatistic> stats) {
    return _buildDataTable(
      columns: ['Rank', 'Club', 'Clean Sheets'],
      rows: stats
          .map(
            (stat) => [
              _buildClubCell(stat),
              Text(
                "${stat.cleanSheetsPercentage}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          )
          .toList(),
    );
  }

  Widget _buildRankingsTable(List<ClubRanking> rankings) {
    return _buildDataTable(
      columns: ['Rank', 'Club', 'Points'],
      rows: rankings
          .map(
            (rank) => [
              _buildClubCellFromRank(rank),
              Text(
                "${rank.points}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
          .toList(),
    );
  }

  Widget _buildDataTable({
    required List<String> columns,
    required List<List<Widget>> rows,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 13,
        ),
        dataTextStyle: GoogleFonts.lato(color: Colors.black87, fontSize: 13),
        columnSpacing: 12,
        horizontalMargin: 12,
        columns: [
          const DataColumn(
            label: SizedBox(
              width: 40,
              child: Text('#', textAlign: TextAlign.center),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: 180,
              child: Text(
                columns[1],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
          if (columns.length > 2)
            DataColumn(
              label: SizedBox(
                width: 110,
                child: Text(
                  columns[2],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
        ],
        rows: rows.asMap().entries.map((entry) {
          int index = entry.key + 1;
          List<Widget> cells = entry.value;
          return DataRow(
            cells: [
              DataCell(
                SizedBox(width: 40, child: Center(child: Text("$index"))),
              ),
              DataCell(SizedBox(width: 180, child: cells[0])),
              if (cells.length > 1)
                DataCell(SizedBox(width: 110, child: cells[1])),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClubCell(TeamStatistic stat) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamDetailPage(clubId: stat.clubId),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (stat.logoUrl != null)
            Image.network(
              stat.logoUrl!,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 24),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              stat.clubName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCellFromRank(ClubRanking rank) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamDetailPage(clubId: rank.clubId),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank.logoUrl != null)
            Image.network(
              rank.logoUrl!,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 24),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              rank.clubName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
