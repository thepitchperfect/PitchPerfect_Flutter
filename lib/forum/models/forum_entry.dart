// To parse this JSON data, do
//
//     final forumEntry = forumEntryFromJson(jsonString);

import 'dart:convert';

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
  List<String> clubs;
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
    title: json["title"],
    content: json["content"],
    postType: json["post_type"],
    author: json["author"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    clubs: List<String>.from(json["clubs"].map((x) => x)),
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
    "clubs": List<dynamic>.from(clubs.map((x) => x)),
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

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    author: json["author"],
    content: json["content"],
    createdAt: DateTime.parse(json["created_at"]),
  );

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
    url: json["url"],
    caption: json["caption"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "caption": caption,
    "order": order,
  };
}
