import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/vote_models.dart';

class StatisticsService {
  // Use 127.0.0.1 for Web/iOS, 10.0.2.2 for Android Emulator
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> fetchGeneralStats(
    CookieRequest request,
  ) async {
    final response = await request.get('$baseUrl/statistics/json/general/');
    // pbp_django_auth automatically decodes JSON if response is JSON
    // But we need to be sure. It returns dynamic.

    // If it's already a Map, good.
    return response;
  }

  static Future<List<dynamic>> fetchSpecificList(
    CookieRequest request,
    String category,
  ) async {
    final response = await request.get(
      '$baseUrl/statistics/json/list/$category/',
    );
    return response['results'];
  }

  static Future<Map<String, dynamic>> fetchTeamDetail(
    CookieRequest request,
    String clubId,
  ) async {
    final response = await request.get(
      '$baseUrl/statistics/json/team/$clubId/',
    );
    return response;
  }

  static Future<Map<String, dynamic>> fetchVoteResults(
    CookieRequest request,
  ) async {
    final response = await request.get(
      '$baseUrl/statistics/json/vote-results/',
    );
    return response;
  }

  static Future<List<SimpleClub>> fetchAllClubs(CookieRequest request) async {
    final response = await request.get('$baseUrl/statistics/json/all-clubs/');
    List<dynamic> data = response['clubs'];
    return data.map((d) => SimpleClub.fromJson(d)).toList();
  }

  static Future<Map<String, dynamic>> voteClub(
    CookieRequest request,
    String clubId,
  ) async {
    final response = await request.postJson(
      '$baseUrl/statistics/json/vote/',
      jsonEncode({'club_id': clubId}),
    );
    return response;
  }
}
