import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/baseUrl.dart';
import 'auth.service.dart';

class MatchService {
  final Dio _dio;
  final AuthService _authService;
  WebSocketChannel? _channel;

  MatchService({
    Dio? dio,
    AuthService? authService,
  })  : _dio = dio ?? Dio(),
        _authService = authService ?? AuthService();

  Future<void> createMatch(Map<String, dynamic> matchData) async {
    const int maxRetries = 3;
    int retryCount = 0;
    int delay = 1;

    while (retryCount < maxRetries) {
      try {
        final userInfo = await _authService.getUserInfo();
        if (userInfo == null || !userInfo.containsKey('id')) {
          throw Exception('Impossible de récupérer l\'ID utilisateur');
        }
        matchData['organizer_id'] = userInfo['id'];

        final accessToken = await _authService.getToken();
        final response = await _dio.post(
          '$baseUrl/matches',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            validateStatus: (status) => status! < 500,
          ),
          data: json.encode(matchData),
        );

        if (response.statusCode == 201) {
          return;
        } else {
          throw Exception('Échec de la création du match: ${response.data}');
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception(
                'Échec de la création du match dû à la limitation de débit: $e');
          }
          await Future.delayed(Duration(seconds: delay));
          delay = delay * 2 > 8 ? 8 : delay * 2;
        } else {
          if (e is DioException) {}
          throw Exception(
              'Échec de la création du match en raison d\'une erreur: $e');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matches',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            'Échec de la récupération des matches: ${response.data}');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des matches');
    }
  }

  Future<Map<String, dynamic>> getMatchDetails(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matches/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Échec de la récupération des détails du match');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des détails du match');
    }
  }

  Future<List<Map<String, dynamic>>> getMatchPlayers(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matchesPlayers/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data.containsKey('players')) {
          return List<Map<String, dynamic>>.from(response.data['players']);
        } else {
          throw Exception('La réponse de l\'API n\'est pas valide');
        }
      } else {
        throw Exception('Échec de la récupération des participants du match');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des participants du match');
    }
  }

  Future<List<Map<String, dynamic>>> getMatchesByOrganizer() async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matches/organizer/matches',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            'Échec de la récupération des matches de l\'organisateur: ${response.data}');
      }
    } catch (e) {
      throw Exception(
          'Échec de la récupération des matches de l\'organisateur');
    }
  }

  Future<void> joinMatch(String matchId, String playerId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.post(
        '$baseUrl/matchesPlayers',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: json.encode({'match_id': matchId, 'player_id': playerId}),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Échec de la tentative de rejoindre le match: ${response.data}');
      }
    } catch (e) {
      throw Exception('Échec de la tentative de rejoindre le match');
    }
  }

  Future<void> leaveMatch(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.post(
        '$baseUrl/matches/$matchId/leave',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Échec de la tentative de quitter le match: ${response.data}');
      }
    } catch (e) {
      throw Exception('Échec de la tentative de quitter le match');
    }
  }

  Future<Map<String, dynamic>> getMatchWithPlayers(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matches/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Échec de la récupération des détails du match avec joueurs');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des détails du match');
    }
  }

  Future<Map<String, dynamic>> isAi(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/openai/formation/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Échec de la récupération des détails du match avec joueurs');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des détails du match');
    }
  }

  Future<bool> isPlayerInMatch(String matchId, String userId) async {
    try {
      final matches = await getMatches();
      for (var match in matches) {
        if (match['id'] == matchId) {
          final players = match['players'] as List<dynamic>;
          return players.any((player) => player['id'] == userId);
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.delete(
        '$baseUrl/matches/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression du match: ${response.data}');
      }
    } catch (e) {
      throw Exception('Échec de la suppression du match');
    }
  }

  Future<Map<String, dynamic>> getCoordinates(String address) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': address,
          'key': 'AIzaSyAdNnq6m3qBSXKlKK5gbQJMdbd22OWeHCg',
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'];
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return {
            'latitude': location['lat'],
            'longitude': location['lng'],
          };
        } else {
          throw Exception(
              'Aucune coordonnée trouvée pour l\'adresse: $address');
        }
      } else {
        throw Exception(
            'Échec de la récupération des coordonnées: ${response.data}');
      }
    } catch (e) {
      throw Exception('Échec de la récupération des coordonnées');
    }
  }

  Future<void> assignReferee(String matchId, String refereeId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.post(
        '$baseUrl/matches/assign-referee',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: json.encode({'match_id': matchId, 'referee_id': refereeId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Échec de l\'attribution de l\'arbitre');
      }
    } catch (e) {
      throw Exception('Échec de l\'attribution de l\'arbitre');
    }
  }

  void connectWebSocket(void Function(Map<String, dynamic>) onMessage) {
    try {
      _channel = WebSocketChannel.connect(
          Uri.parse('$baseUrl/matches/status/updates'));
      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          onMessage(data);
        },
        onError: (error) {},
        onDone: () {},
      );
      // ignore: empty_catches
    } catch (e) {}
  }

  void closeWebSocket() {
    _channel?.sink.close();
  }
}
