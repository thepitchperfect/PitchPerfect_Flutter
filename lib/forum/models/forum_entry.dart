// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';
import '../../clubdirectory/models/club_model.dart';

List<ForumEntry> forumEntryFromJson(String str) => List<ForumEntry>.from(json.decode(str).map((x) => ForumEntry.fromJson(x)));

String forumEntryToJson(List<ForumEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForumEntry {
  int id;
  String title;
  String content;
  String postType;
  String author;
  DateTime createdAt;
  DateTime updatedAt;
  List<Club> clubs;
  List<Image> images;
  List<Comment> comments;

  ForumEntry({
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

  factory ForumEntry.fromJson(Map<String, dynamic> json) => ForumEntry(
    id: json["id"],
    title: json["title"] ?? 'No Title',
    content: json["content"] ?? '',
    postType: json["post_type"] ?? 'Discussion',
    author: json["author"] ?? 'Unknown Author',
    createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : DateTime.now(),
    clubs: List<Club>.from(json["clubs"].map((x) => Club.fromJson(x))),
    images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
    comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "post_type": postType,
    "author": author,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "clubs": List<dynamic>.from(clubs.map((x) => x.toJson())),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
  };
}

class Comment {
  String author;
  String content;
  DateTime createdAt;

  Comment({
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final authorData = json["author"];
    String authorName;

    if (authorData is String) {
      authorName = authorData;
    } else if (authorData is Map && authorData.containsKey("username") && authorData["username"] != null) {
      authorName = authorData["username"];
    } else {
      authorName = "Unknown Author";
    }

    return Comment(
      author: authorName,
      content: json["content"] ?? "",
      createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "author": author,
    "content": content,
    "created_at": createdAt.toIso8601String(),
  };
}

class Image {
  String url;
  String caption;
  int order;

  Image({
    required this.url,
    required this.caption,
    required this.order,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    url: json["url"] ?? '',
    caption: json["caption"] ?? '',
    order: json["order"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "caption": caption,
    "order": order,
  };
}
