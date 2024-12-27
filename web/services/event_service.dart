import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/utils/basUrl.dart';

class EventService {
  final AuthService authService;
  EventService(this.authService);

  Future<void> addEventToMatch(String matchId, String eventType, String player, int minute) async {
    final url = Uri.parse('$baseUrl/matches/$matchId/events');
    final body = {
      'type': eventType,
      'player': player,
      'minute': minute,
    };
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authService.getToken}'
        },
        body: json.encode(body));

    if (response.statusCode != 201) {
      throw Exception('Failed to add event');
    }
  }
}
