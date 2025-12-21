import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../../clubdirectory/models/club_model.dart';

class MatchPredictionForm extends StatefulWidget {
  const MatchPredictionForm({super.key});

  @override
  State<MatchPredictionForm> createState() =>
      _MatchPredictionFormState();
}

class _MatchPredictionFormState
    extends State<MatchPredictionForm> {
  // ---------------- FORM STATE ----------------
  String? selectedLeagueId;
  String? selectedHomeTeamId;
  String? selectedAwayTeamId;
  DateTime? matchDate;
  String status = "upcoming";

  late Future<List<League>> _futureLeagues;

  @override
  void initState() {
    super.initState();
    _futureLeagues = fetchLeagues();
  }

  // ---------------- FETCH LEAGUES ----------------
  Future<List<League>> fetchLeagues() async {
    final request = context.read<CookieRequest>();

    final baseUrl = Platform.isAndroid
        ? "http://10.0.2.2:8000"
        : "http://localhost:8000";

    final response =
        await request.get("$baseUrl/directory/json/");

    final List leagueList =
        response is Map ? response['leagues'] : response;

    return leagueList
        .map((e) => League.fromJson(e))
        .toList();
  }

  // ---------------- SUBMIT (ADMIN ONLY) ----------------
  Future<void> submitForm() async {
    if (selectedLeagueId == null ||
        selectedHomeTeamId == null ||
        selectedAwayTeamId == null ||
        matchDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("⚠️ Please fill all fields")),
      );
      return;
    }

    final request = context.read<CookieRequest>();

    final baseUrl = Platform.isAndroid
        ? "http://10.0.2.2:8000"
        : "http://localhost:8000";

    final response = await request.post(
      "$baseUrl/predictions/add/api/",
      {
        "league": selectedLeagueId,
        "home_team": selectedHomeTeamId,
        "away_team": selectedAwayTeamId,
        "match_date": matchDate!.toIso8601String(),
        "status": status,
      },
    );

    // ✅ SUCCESS → tell previous screen to refresh
    if (response["status"] == "success") {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ ${response["message"] ?? "Failed to save match"}",
          ),
        ),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Match")),
      body: FutureBuilder<List<League>>(
        future: _futureLeagues,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}"));
          }

          final leagues = snapshot.data!;
          final selectedLeague = leagues
              .where((l) => l.id == selectedLeagueId)
              .firstOrNull;

          final clubs =
              selectedLeague?.clubs ?? <Club>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _dropdown(
                  label: "League",
                  value: selectedLeagueId,
                  items: leagues.map((l) {
                    return DropdownMenuItem(
                      value: l.id,
                      child: Text(l.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedLeagueId = v;
                      selectedHomeTeamId = null;
                      selectedAwayTeamId = null;
                    });
                  },
                ),
                _dropdown(
                  label: "Home team",
                  value: selectedHomeTeamId,
                  items: clubs.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() =>
                          selectedHomeTeamId = v),
                ),
                _dropdown(
                  label: "Away team",
                  value: selectedAwayTeamId,
                  items: clubs.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() =>
                          selectedAwayTeamId = v),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Match date",
                  style: TextStyle(
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final date =
                        await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                      initialDate: DateTime.now(),
                    );

                    if (date != null) {
                      setState(() {
                        matchDate = date;
                      });
                    }
                  },
                  child: Text(
                    matchDate == null
                        ? "Select date"
                        : matchDate!
                            .toLocal()
                            .toString(),
                  ),
                ),
                const SizedBox(height: 16),
                _dropdown(
                  label: "Status",
                  value: status,
                  items: const [
                    DropdownMenuItem(
                        value: "upcoming",
                        child: Text("upcoming")),
                    DropdownMenuItem(
                        value: "finished",
                        child: Text("finished")),
                  ],
                  onChanged: (v) =>
                      setState(() => status = v!),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- HELPER ----------------
  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
