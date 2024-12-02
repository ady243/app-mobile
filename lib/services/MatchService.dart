import 'dart:convert';
import 'package:dio/dio.dart';
import '../utils/basUrl.dart';
import 'auth.service.dart';

class MatchService {
  final Dio _dio;
  final AuthService _authService;

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
          print('Match créé avec succès: ${response.data}');
          return;
        } else {
          print('Échec de la création du match: ${response.statusCode} - ${response.data}');
          throw Exception('Échec de la création du match: ${response.data}');
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            print('Nombre maximal de tentatives atteint. Erreur: $e');
            throw Exception('Échec de la création du match dû à la limitation de débit: $e');
          }
          print('Limite de débit dépassée. Nouvelle tentative dans $delay secondes...');
          await Future.delayed(Duration(seconds: delay));
          delay = delay * 2 > 8 ? 8 : delay * 2;
        } else {
          if (e is DioException) {
            print('Erreur lors de la création du match: ${e.response?.data}');
            print('Statut de la réponse: ${e.response?.statusCode}');
          }
          throw Exception('Échec de la création du match en raison d\'une erreur: $e');
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
        throw Exception('Échec de la récupération des matches: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des matches: $e');
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
      throw Exception('Erreur lors de la récupération des détails du match: $e');
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
      throw Exception('Erreur lors de la récupération des participants du match: $e');
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
        throw Exception('Échec de la récupération des matches de l\'organisateur: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des matches de l\'organisateur: $e');
      throw Exception('Échec de la récupération des matches de l\'organisateur');
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

      print('Réponse du serveur: ${response.data}');

      if (response.statusCode != 201) {
        throw Exception('Échec de la tentative de rejoindre le match: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la tentative de rejoindre le match: $e');
      throw Exception('Échec de la tentative de rejoindre le match');
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
        throw Exception('Échec de la récupération des détails du match avec joueurs');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails du match: $e');
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
        throw Exception('Échec de la récupération des détails du match avec joueurs');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails du match: $e');
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
      print('Erreur lors de la vérification de l\'adhésion du joueur: $e');
      return false;
    }
  }

  Future<void> deleteMatch(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      print('Tentative de suppression du match avec ID: $matchId');
      final response = await _dio.delete(
        '$baseUrl/matches/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 204) {
        print('Match supprimé avec succès');
      } else {
        print('Échec de la suppression du match: ${response.statusCode} - ${response.data}');
        throw Exception('Échec de la suppression du match: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la suppression du match: $e');
      throw Exception('Échec de la suppression du match');
    }
  }
}