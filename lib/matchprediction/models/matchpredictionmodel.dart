// To parse this JSON data, do
//
//     final matchprediction = matchpredictionFromJson(jsonString);

import 'dart:convert';

List<Matchprediction> matchpredictionFromJson(String str) =>
    List<Matchprediction>.from(
        json.decode(str).map((x) => Matchprediction.fromJson(x)));

String matchpredictionToJson(List<Matchprediction> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Matchprediction {
  String id;
  AwayTeam league;
  AwayTeam homeTeam;
  AwayTeam awayTeam;
  DateTime matchDate;
  String status;
  int totalVotes;
  VoteSummary voteSummary;

  final String? userVote;
  

  Matchprediction({
    required this.id,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.matchDate,
    required this.status,
    required this.totalVotes,
    required this.voteSummary,
    required this.userVote,
  });

  factory Matchprediction.fromJson(Map<String, dynamic> json) =>
      Matchprediction(
        id: json["id"],
        league: AwayTeam.fromJson(json["league"]),
        homeTeam: AwayTeam.fromJson(json["home_team"]),
        awayTeam: AwayTeam.fromJson(json["away_team"]),
        matchDate: DateTime.parse(json["match_date"]),
        status: json["status"],
        totalVotes: json["total_votes"],
        voteSummary: VoteSummary.fromJson(json["vote_summary"]),
        userVote: json["user_vote"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "league": league.toJson(),
        "home_team": homeTeam.toJson(),
        "away_team": awayTeam.toJson(),
        "match_date": matchDate.toIso8601String(),
        "status": status,
        "total_votes": totalVotes,
        "vote_summary": voteSummary.toJson(),
      };
}

class AwayTeam {
  String id;
  String name;

  AwayTeam({
    required this.id,
    required this.name,
  });

  factory AwayTeam.fromJson(Map<String, dynamic> json) => AwayTeam(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class VoteSummary {
  double homeWin;
  double awayWin;
  double draw;

  VoteSummary({
    required this.homeWin,
    required this.awayWin,
    required this.draw,
  });

  factory VoteSummary.fromJson(Map<String, dynamic> json) => VoteSummary(
        homeWin: (json["home_win"] as num).toDouble(),
        awayWin: (json["away_win"] as num).toDouble(),
        draw: (json["draw"] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "home_win": homeWin,
        "away_win": awayWin,
        "draw": draw,
      };
}