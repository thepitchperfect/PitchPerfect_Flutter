import 'package:flutter/material.dart';

import '../models/matchpredictionmodel.dart';
import '../screens/matchprediction_detail.dart';
import '../../clubdirectory/models/club_model.dart';

class MatchCard extends StatelessWidget {
  final Matchprediction match;
  final Map<String, Club> clubMap;

  const MatchCard({
    super.key,
    required this.match,
    required this.clubMap,
  });

  @override
  Widget build(BuildContext context) {
    final votes = match.voteSummary;

    final homeClub = clubMap[match.homeTeam.id];
    final awayClub = clubMap[match.awayTeam.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔵 LEAGUE + DATE
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 28),
              const SizedBox(width: 8),
              Text(
                match.league.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(match.matchDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔵 TEAMS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _teamColumn(match.homeTeam.name, homeClub),
              const Text("vs", style: TextStyle(fontWeight: FontWeight.bold)),
              _teamColumn(match.awayTeam.name, awayClub),
            ],
          ),

          const SizedBox(height: 14),

          // 🔵 WIN PROBABILITY
          Column(
            children: [
              const Text(
                "WIN PROBABILITY",
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              match.totalVotes > 0
                  ? Text(
                      "H ${votes.homeWin}% | D ${votes.draw}% | A ${votes.awayWin}%",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  : const Text(
                      "No votes yet",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔵 VOTE BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchPredictionDetail(match: match),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Vote Now"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 TEAM COLUMN (CLUB LOGO)
  Widget _teamColumn(String name, Club? club) {
    return Column(
      children: [
        club?.logoUrl != null
            ? Image.network(
                _fullUrl(club!.logoUrl!),
                width: 56,
                height: 56,
                fit: BoxFit.contain,
              )
            : const Icon(Icons.shield, size: 56),

        const SizedBox(height: 6),

        SizedBox(
          width: 90,
          child: Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // ✅ FIXED URL HANDLER (THIS WAS THE BUG)
  String _fullUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path; // already absolute (e.g. Wikimedia)
    }
    return "http://10.0.2.2:8000$path"; // Django media path
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} "
        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
