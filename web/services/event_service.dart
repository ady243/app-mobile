import 'dart:convert';
import 'package:http/http.dart' as http;
import 'authweb_service.dart';
import 'package:teamup/utils/basUrl.dart';

class EventService {
  final AuthWebService authWebService;
  EventService(this.authWebService);

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
          'Authorization': 'Bearer ${authWebService.getToken}'
        },
        body: json.encode(body));

    if (response.statusCode != 201) {
      throw Exception('Failed to add event');
    }
  }
}
