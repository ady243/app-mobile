import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/baseUrl.dart';
import 'auth.service.dart';

class ChatService {
  final Dio _dio;
  final AuthService _authService;


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
          '$baseUrl/chat/send',
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
        '$baseUrl/chat/$matchId',
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
        '$baseUrl/matchesPlayers/$matchId/$userId',
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
  Future<bool> hasNewMessages(String matchId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/chat/$matchId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> messages = response.data;
        if (messages.isEmpty) return false;

        String lastMessageTimestamp = messages.last['timestamp'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? lastReadTimestamp = prefs.getString('lastReadTimestamp_$matchId');

        if (lastReadTimestamp == null || lastMessageTimestamp.compareTo(lastReadTimestamp) > 0) {
          return true;
        }
        return false;
      } else {
        throw Exception('Échec de la vérification des nouveaux messages: ${response.data}');
      }
    } catch (e) {
      print('Erreur lors de la vérification des nouveaux messages: $e');
      return false;
    }
  }

  Future<void> markMessagesAsRead(String matchId) async {
    try {
      List<Map<String, dynamic>> messages = await getMessages(matchId);
      if (messages.isNotEmpty) {
        String lastMessageTimestamp = messages.last['timestamp'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastReadTimestamp_$matchId', lastMessageTimestamp);
      }
    } catch (e) {
      print('Erreur lors du marquage des messages comme lus: $e');
    }
  }
}