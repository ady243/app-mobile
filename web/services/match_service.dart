import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authweb_service.dart';
import '../utils/baseUrl.dart';

class MatchService {
  final AuthWebService authWebService;
  MatchService(this.authWebService);

  Future<List<Map<String, dynamic>>> getAnalystMatches() async {
    final token = await authWebService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Aucun token disponible.');
    }
    final url = Uri.parse('$baseUrl/matches/referee/matches');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch matches');
    }
  }
}