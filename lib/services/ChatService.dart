import 'dart:convert';
import 'package:dio/dio.dart';
import 'auth.service.dart';

class ChatService {
  final Dio _dio;
  final AuthService _authService;
  //final String apiUrl = 'http://10.0.2.2:3003/api';
  final String apiUrl = 'http://127.0.0.1:3003/api';

  ChatService({
    Dio? dio,
    AuthService? authService,
  })  : _dio = dio ?? Dio(),
        _authService = authService ?? AuthService();

  Future<void> sendMessage(String matchId, String userId, String message) async {
    const int maxRetries = 3;
    int retryCount = 0;
    int delay = 1;

    while (retryCount < maxRetries) {
      try {
        final accessToken = await _authService.getToken();
        final response = await _dio.post(
          '$apiUrl/chat/send',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          data: json.encode({'match_id': matchId, 'user_id': userId, 'message': message}),
        );

        if (response.statusCode == 200) {
          return;
        } else {
          throw Exception('Échec de l\'envoi du message: ${response.data}');
        }
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 429) {
          retryCount++;
          if (retryCount >= maxRetries) {
            print('Nombre maximal de tentatives atteint. Erreur: $e');
            throw Exception('Échec de l\'envoi du message dû à la limitation de débit: $e');
          }
          print('Limite de débit dépassée. Nouvelle tentative dans $delay secondes...');
          await Future.delayed(Duration(seconds: delay));
          delay = delay * 2 > 8 ? 8 : delay * 2;
        } else {
          print('Erreur lors de l\'envoi du message: $e');
          throw Exception('Échec de l\'envoi du message');
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$apiUrl/chat/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Échec de la récupération des messages: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des messages: $e');
      throw Exception('Échec de la récupération des messages');
    }
  }

  Future<bool> isPlayerInMatch(String matchId, String userId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$apiUrl/matchesPlayers/$matchId/$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erreur lors de la vérification de l\'adhésion du joueur: $e');
      return false;
    }
  }
}