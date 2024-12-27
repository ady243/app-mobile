import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/utils/basUrl.dart';

class MatchService {
  final AuthService authService;
  MatchService(this.authService);

  Future<List<Map<String, dynamic>>> getRefereeMatches() async {
    final url = Uri.parse('$baseUrl/matches/referee/matches');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authService.getToken}'
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch matches');
    }
  }

  Future<void> recordEvent(String matchId, String eventType) async {
    final url = Uri.parse('http://localhost:8080/matches/$matchId/events'); // A adapter
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authService.getToken}'
      },
      body: json.encode({'eventType': eventType}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to record event');
    }
  }
}