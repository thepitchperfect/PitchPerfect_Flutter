class Award {
  final String title;
  final String awardType;
  final String season;
  final String date;
  final String description;

  Award({
    required this.title,
    required this.awardType,
    required this.season,
    required this.date,
    required this.description,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      title: json['title'] ?? '',
      awardType: json['award_type'] ?? '',
      season: json['season'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ClubAwards {
  final String clubName;
  final String clubId;
  final String? logoUrl;
  final int awardCount;
  final List<Award> awards;

  ClubAwards({
    required this.clubName,
    required this.clubId,
    this.logoUrl,
    required this.awardCount,
    required this.awards,
  });

  factory ClubAwards.fromJson(Map<String, dynamic> json) {
    var list = json['awards'] as List;
    List<Award> awardsList = list.map((i) => Award.fromJson(i)).toList();

    return ClubAwards(
      clubName: json['club_name'] ?? 'Unknown',
      clubId: json['club_id'] ?? '',
      logoUrl: json['logo_url'],
      awardCount: json['award_count'] ?? 0,
      awards: awardsList,
    );
  }
}
