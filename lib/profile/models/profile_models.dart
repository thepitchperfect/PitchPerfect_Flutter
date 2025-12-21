// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

List<Profile> profileFromJson(String str) =>
    List<Profile>.from(json.decode(str).map((x) => Profile.fromJson(x)));

String profileToJson(List<Profile> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Profile {
  String username;
  String email;
  String fullName;
  String? profpict;
  String role;
  bool isActive;
  bool isStaff;

  Profile({
    required this.username,
    required this.email,
    required this.fullName,
    this.profpict,
    required this.role,
    required this.isActive,
    required this.isStaff,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    username: json["username"],
    email: json["email"],
    fullName: json["full_name"],
    profpict: json["profpict"],
    role: json["role"],
    isActive: json["is_active"],
    isStaff: json["is_staff"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "full_name": fullName,
    "profpict": profpict,
    "role": role,
    "is_active": isActive,
    "is_staff": isStaff,
  };
}
