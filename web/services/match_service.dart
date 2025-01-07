import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/utils/basUrl.dart';

class MatchService {
  final AuthService authService;
  MatchService(this.authService);

  Future<List<Map<String, dynamic>>> getAnalystMatches() async {
    final token = await authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Aucun token disponible.');
    }
    final url = Uri.parse('$baseUrl/matches/analyst/matches');
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