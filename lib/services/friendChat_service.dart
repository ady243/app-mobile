import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:teamup/models/message.dart';
import 'package:teamup/services/auth.service.dart';
import '../utils/baseUrl.dart';

class FriendChatService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<void> sendMessage(Message message) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final token = userInfo['refresh_token'];

    try {
      final data = jsonEncode(message.toJson());
      print('Sending message data: $data');

      final response = await _dio.post(
        '$baseUrl/message/send',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<Message>> getMessages(String senderId, String receiverId) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final token = userInfo['refresh_token'];

    try {
      print(
          'Fetching messages for senderId: $senderId and receiverId: $receiverId');

      final response = await _dio.get(
        '$baseUrl/message/messages/$senderId/$receiverId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> body = response.data;
        return body.map((dynamic item) => Message.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Failed to load messages: $e');
    }
  }
}