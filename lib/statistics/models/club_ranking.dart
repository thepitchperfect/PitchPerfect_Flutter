class ClubRanking {
  final String clubName;
  final String clubId;
  final String? logoUrl;
  final int rank;
  final double points;
  final String continent;
  final String rankingDate;
  final int? previousRank;

  ClubRanking({
    required this.clubName,
    required this.clubId,
    this.logoUrl,
    required this.rank,
    required this.points,
    required this.continent,
    required this.rankingDate,
    this.previousRank,
  });

  factory ClubRanking.fromJson(Map<String, dynamic> json) {
    return ClubRanking(
      clubName: json['club_name'] ?? 'Unknown',
      clubId: json['club_id'] ?? '',
      logoUrl: json['logo_url'],
      rank: json['rank'] ?? 0,
      points: (json['points'] ?? 0).toDouble(),
      continent: json['continent'] ?? '',
      rankingDate: json['ranking_date'] ?? '',
      previousRank: json['previous_rank'],
    );
  }
}
