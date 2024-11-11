class MatchService {
  // Simulate fetching all matches with static data
  Future<List<Match>> fetchMatches() async {
    // Simulated static match data
    return [
      Match(
        id: '1',
        organizer: 'Organisateur 1',
        address: '123 Rue du Match',
        status: 'ongoing',
        matchDate: DateTime.now(),
      ),
      Match(
        id: '2',
        organizer: 'Organisateur 2',
        address: '456 Rue du Sport',
        status: 'upcoming',
        matchDate: DateTime.now().add(Duration(days: 5)),
      ),
      Match(
        id: '3',
        organizer: 'Organisateur 3',
        address: '789 Rue de la Victoire',
        status: 'completed',
        matchDate: DateTime.now().subtract(Duration(days: 10)),
      ),
      Match(
        id: '4',
        organizer: 'Organisateur 4',
        address: '1010 Rue du Stade',
        status: 'upcoming',
        matchDate: DateTime.now().add(Duration(days: 15)),
      ),
    ];
  }
}

// Match model for static data
class Match {
  final String id;
  final String organizer;
  final String address;
  final String status;
  final DateTime matchDate;

  Match({
    required this.id,
    required this.organizer,
    required this.address,
    required this.status,
    required this.matchDate,
  });

// No need for fromJson method as we are using static data
}




/*import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MatchService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  MatchService() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));

    // Optional: Add authorization header if needed
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Fetch all matches
  Future<List<Match>> fetchMatches() async {
    try {
      final response = await _dio.get('http://127.0.0.1:3003/api/matches'); // Update with correct API endpoint
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des matchs.');
      }
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }
}

// Match model for parsing JSON data
class Match {
  final String id;
  final String organizer;
  final String address;
  final String status;
  final DateTime matchDate;

  Match({
    required this.id,
    required this.organizer,
    required this.address,
    required this.status,
    required this.matchDate,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      organizer: json['organizer'],
      address: json['address'],
      status: json['status'],
      matchDate: DateTime.parse(json['date']),
    );
  }
}
*/