import 'dart:async';
import 'package:flutter/material.dart';

import '../screens/matchprediction_list.dart';
import '../screens/matchprediction_forum.dart';

class MatchPredictionMain extends StatefulWidget {
  const MatchPredictionMain({super.key});

  @override
  State<MatchPredictionMain> createState() => _MatchPredictionMainState();
}

class _MatchPredictionMainState extends State<MatchPredictionMain> {
  String selectedLeagueName = '';
  String filterType = 'all';
  String searchQuery = '';

  // 🔥 AUTO SCROLL
  late final ScrollController _leagueScrollController;
  Timer? _autoScrollTimer;
  bool _scrollForward = true;

  @override
  void initState() {
    super.initState();

    _leagueScrollController = ScrollController();
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (_) => _autoScroll(),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _leagueScrollController.dispose();
    super.dispose();
  }

  void _autoScroll() {
    if (!_leagueScrollController.hasClients) return;

    final maxScroll =
        _leagueScrollController.position.maxScrollExtent;
    final minScroll =
        _leagueScrollController.position.minScrollExtent;
    final current = _leagueScrollController.offset;

    const step = 1.0;

    if (_scrollForward) {
      if (current >= maxScroll) {
        _scrollForward = false;
      } else {
        _leagueScrollController.jumpTo(current + step);
      }
    } else {
      if (current <= minScroll) {
        _scrollForward = true;
      } else {
        _leagueScrollController.jumpTo(current - step);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔵 HEADER
            Column(
              children: const [
                Text(
                  "Match Predictions",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Vote for your favorite club and see what others predict!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔵 LEAGUE FILTER (AUTO SCROLL)
            SingleChildScrollView(
              controller: _leagueScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _leagueButton("All Leagues", ''),
                  _leagueButton("Premier League", "Premier League"),
                  _leagueButton("La Liga", "La Liga"),
                  _leagueButton("Serie A", "Serie A"),
                  _leagueButton("Bundesliga", "Bundesliga"),
                  _leagueButton("Ligue 1", "Ligue 1 McDonald's"),
                  _leagueButton("Primeira Liga", "Primeira Liga"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔵 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (val) {
                  setState(() => searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: "Search your favorite club...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔵 ADD MATCH BUTTON (NEW)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MatchPredictionForm(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Match"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔵 FILTER BUTTONS
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _filterButton("All Matches", 'all'),
                  _filterButton("My Predictions", 'my'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔵 MATCH LIST
            Expanded(
              child: MatchListScreen(
                leagueName: selectedLeagueName,
                filterType: filterType,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // 🔹 UI HELPERS
  // ==========================

  Widget _leagueButton(String text, String leagueName) {
    final isActive = selectedLeagueName == leagueName;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() => selectedLeagueName = leagueName);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.amber : Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _filterButton(String text, String type) {
    final isActive = filterType == type;

    return TextButton(
      onPressed: () {
        setState(() => filterType = type);
      },
      style: TextButton.styleFrom(
        backgroundColor:
            isActive ? Colors.amber : Colors.transparent,
        foregroundColor: Colors.black,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(text),
    );
  }
}
