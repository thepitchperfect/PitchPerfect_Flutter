import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../clubdirectory/models/club_model.dart';

Future<List<Club>> fetchClubs() async {
  final uri = Uri.parse('http://10.0.2.2:8000/club-directory/json/');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((e) => Club.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load clubs');
  }
}
