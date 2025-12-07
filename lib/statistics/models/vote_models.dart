class VoteResult {
  final String clubName;
  final String? logoUrl;
  final int voteCount;

  VoteResult({required this.clubName, this.logoUrl, required this.voteCount});

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      clubName: json['club_name'] ?? 'Unknown',
      logoUrl: json['logo_url'],
      voteCount: json['vote_count'] ?? 0,
    );
  }
}

class SimpleClub {
  final String id;
  final String name;
  final String? logoUrl;

  SimpleClub({required this.id, required this.name, this.logoUrl});

  factory SimpleClub.fromJson(Map<String, dynamic> json) {
    return SimpleClub(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      logoUrl: json['logo_url'],
    );
  }
}
