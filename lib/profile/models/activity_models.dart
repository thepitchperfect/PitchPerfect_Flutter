import 'dart:convert';

UserActivity userActivityFromJson(String str) =>
    UserActivity.fromJson(json.decode(str));

String userActivityToJson(UserActivity data) => json.encode(data.toJson());

class UserActivity {
  String username;
  List<LeaguePick> leaguePicks;
  List<UserPost> userPosts;
  List<UserPrediction> userPredictions;

  UserActivity({
    required this.username,
    required this.leaguePicks,
    required this.userPosts,
    required this.userPredictions,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) => UserActivity(
    username: json["username"] ?? "Unknown",
    leaguePicks: json["league_picks"] == null
        ? []
        : List<LeaguePick>.from(
            json["league_picks"].map((x) => LeaguePick.fromJson(x)),
          ),
    userPosts: json["user_posts"] == null
        ? []
        : List<UserPost>.from(
            json["user_posts"].map((x) => UserPost.fromJson(x)),
          ),
    userPredictions: json["user_predictions"] == null
        ? []
        : List<UserPrediction>.from(
            json["user_predictions"].map((x) => UserPrediction.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "league_picks": List<dynamic>.from(leaguePicks.map((x) => x.toJson())),
    "user_posts": List<dynamic>.from(userPosts.map((x) => x.toJson())),
    "user_predictions": List<dynamic>.from(
      userPredictions.map((x) => x.toJson()),
    ),
  };
}

class LeaguePick {
  String id;
  String name;
  String logoUrl;
  int foundedYear;
  String desc;
  bool isLeaguePick;

  LeaguePick({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.foundedYear,
    required this.desc,
    required this.isLeaguePick,
  });

  factory LeaguePick.fromJson(Map<String, dynamic> json) => LeaguePick(
    id: json["id"]?.toString() ?? "", 
    name: json["name"] ?? "Unknown Club",
    logoUrl: json["logo_url"] ?? "", 
    foundedYear: json["founded_year"] ?? 0,
    desc: json["desc"] ?? "",
    isLeaguePick: json["is_league_pick"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "logo_url": logoUrl,
    "founded_year": foundedYear,
    "desc": desc,
    "is_league_pick": isLeaguePick,
  };
}

class UserPost {
  int id;
  String title;
  String content;
  String postType;
  String author;
  DateTime createdAt;
  DateTime updatedAt;
  List<dynamic> clubs;
  List<dynamic> images;
  List<dynamic> comments;

  UserPost({
    required this.id,
    required this.title,
    required this.content,
    required this.postType,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.clubs,
    required this.images,
    required this.comments,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
    id: json["id"],
    title: json["title"] ?? "",
    content: json["content"] ?? "",
    postType: json["post_type"] ?? "general",
    author: json["author"] ?? "Anonymous",
    createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
    clubs: json["clubs"] == null
        ? []
        : List<dynamic>.from(json["clubs"].map((x) => x)),
    images: json["images"] == null
        ? []
        : List<dynamic>.from(json["images"].map((x) => x)),
    comments: json["comments"] == null
        ? []
        : List<dynamic>.from(json["comments"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "post_type": postType,
    "author": author,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "clubs": List<dynamic>.from(clubs.map((x) => x)),
    "images": List<dynamic>.from(images.map((x) => x)),
    "comments": List<dynamic>.from(comments.map((x) => x)),
  };
}

class UserPrediction {
  String id;
  String matchTitle;
  String votedFor;
  DateTime matchDate;

  UserPrediction({
    required this.id,
    required this.matchTitle,
    required this.votedFor,
    required this.matchDate,
  });

  factory UserPrediction.fromJson(Map<String, dynamic> json) => UserPrediction(
    id: json["id"]?.toString() ?? "",
    matchTitle: json["match_title"] ?? "Unknown Match",
    votedFor: json["voted_for"] ?? "Unknown",
    matchDate: DateTime.tryParse(json["match_date"] ?? "") ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "match_title": matchTitle,
    "voted_for": votedFor,
    "match_date":
        "${matchDate.year.toString().padLeft(4, '0')}-${matchDate.month.toString().padLeft(2, '0')}-${matchDate.day.toString().padLeft(2, '0')}",
  };
}
