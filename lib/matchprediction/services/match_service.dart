import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matchpredictionmodel.dart';

Future<List<Matchprediction>> fetchMatches({
  String? leagueId,
  String? search,
  String filter = 'all',
}) async {
  final query = {
    if (leagueId != null && leagueId.isNotEmpty) 'league': leagueId,
    if (search != null && search.isNotEmpty) 'search': search,
    'filter': filter,
  };

  final uri = Uri.http(
    '10.0.2.2:8000',
    '/predictions/json/',
    query,
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return matchpredictionFromJson(response.body);
  } else {
    throw Exception('Failed to load matches');
  }
}
