class Club {
  final String id;
  final String name;
  final String? logoUrl;
  final int? foundedYear;
  final String? description;
  bool isLeaguePick; 

  Club({
    required this.id,
    required this.name,
    this.logoUrl,
    this.foundedYear,
    this.description,
    this.isLeaguePick = false,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'].toString(),
      name: json['name'],
      logoUrl: json['logo_url'],
      foundedYear: json['founded_year'],
      description: json['desc'],
      isLeaguePick: json['is_league_pick'] ?? false, 
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo_url": logoUrl,
  };
}

class League {
  final String id;
  final String name;
  final String region;
  final String? logoPath;
  final double latitude;
  final double longitude;
  final List<Club> clubs;

  League({
    required this.id,
    required this.name,
    required this.region,
    this.logoPath,
    required this.latitude,
    required this.longitude,
    required this.clubs,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    var list = json['clubs'] as List;
    List<Club> clubList = list.map((i) => Club.fromJson(i)).toList();

    double lat = 48.8566;
    double lng = 2.3522;

    if (json['coords'] != null && json['coords'] is List && (json['coords'] as List).length >= 2) {
      final coords = json['coords'] as List;
      lat = (coords[0] as num).toDouble();
      lng = (coords[1] as num).toDouble();
    } 
    else if (json['coordinate_lat'] != null) {
       lat = (json['coordinate_lat'] as num).toDouble();
       lng = (json['coordinate_lng'] as num).toDouble();
    }

    return League(
      id: json['id'].toString(),
      name: json['name'],
      region: json['region'] ?? 'Europe',
      logoPath: json['logo_path'],
      latitude: lat,
      longitude: lng,
      clubs: clubList,
    );
  }
}