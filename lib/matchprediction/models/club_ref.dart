class ClubRef {
  final String id;
  final String name;
  final String? logoUrl;

  ClubRef({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory ClubRef.fromJson(Map<String, dynamic> json) {
    return ClubRef(
      id: json['id'].toString(),
      name: json['name'],
      logoUrl: json['logo_url'],
    );
  }
}
