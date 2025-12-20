class TeamStatistic {
  final String clubName;
  final String clubId;
  final String? logoUrl;
  final String season;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final double winPercentage;
  final double scoredPerMatch;
  final double concededPerMatch;
  final double avgMatchGoals;
  final double cleanSheetsPercentage;
  final double failedToScorePercentage;
  final double possessionAvg;
  final double shotsTakenPerMatch;
  final double shotsConversionRate;
  final double foulsCommittedPerMatch;
  final double fouledAgainstPerMatch;
  final String penaltiesWon;
  final String penaltiesConceded;
  final double goalKicksPerMatch;
  final double throwInsPerMatch;
  final double freeKicksPerMatch;

  TeamStatistic({
    required this.clubName,
    required this.clubId,
    this.logoUrl,
    required this.season,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.winPercentage,
    required this.scoredPerMatch,
    required this.concededPerMatch,
    required this.avgMatchGoals,
    required this.cleanSheetsPercentage,
    required this.failedToScorePercentage,
    required this.possessionAvg,
    required this.shotsTakenPerMatch,
    required this.shotsConversionRate,
    required this.foulsCommittedPerMatch,
    required this.fouledAgainstPerMatch,
    required this.penaltiesWon,
    required this.penaltiesConceded,
    required this.goalKicksPerMatch,
    required this.throwInsPerMatch,
    required this.freeKicksPerMatch,
  });

  factory TeamStatistic.fromJson(Map<String, dynamic> json) {
    return TeamStatistic(
      clubName: json['club_name'] ?? 'Unknown',
      clubId: json['club_id'] ?? '',
      logoUrl: json['logo_url'],
      season: json['season'] ?? '',
      matchesPlayed: json['matches_played'] ?? 0,
      wins: json['wins'] ?? 0,
      draws: json['draws'] ?? 0,
      losses: json['losses'] ?? 0,
      winPercentage: (json['win_percentage'] ?? 0).toDouble(),
      scoredPerMatch: (json['scored_per_match'] ?? 0).toDouble(),
      concededPerMatch: (json['conceded_per_match'] ?? 0).toDouble(),
      avgMatchGoals: (json['avg_match_goals'] ?? 0).toDouble(),
      cleanSheetsPercentage: (json['clean_sheets_percentage'] ?? 0).toDouble(),
      failedToScorePercentage: (json['failed_to_score_percentage'] ?? 0)
          .toDouble(),
      possessionAvg: (json['possession_avg'] ?? 0).toDouble(),
      shotsTakenPerMatch: (json['shots_taken_per_match'] ?? 0).toDouble(),
      shotsConversionRate: (json['shots_conversion_rate'] ?? 0).toDouble(),
      foulsCommittedPerMatch: (json['fouls_committed_per_match'] ?? 0)
          .toDouble(),
      fouledAgainstPerMatch: (json['fouled_against_per_match'] ?? 0).toDouble(),
      penaltiesWon: json['penalties_won'] ?? '',
      penaltiesConceded: json['penalties_conceded'] ?? '',
      goalKicksPerMatch: (json['goal_kicks_per_match'] ?? 0).toDouble(),
      throwInsPerMatch: (json['throw_ins_per_match'] ?? 0).toDouble(),
      freeKicksPerMatch: (json['free_kicks_per_match'] ?? 0).toDouble(),
    );
  }
}
