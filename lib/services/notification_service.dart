import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teamup/utils/baseUrl.dart';

class NotificationService {
  final Dio _dio = Dio();

  Future<void> sendPushNotification(
      String token, String title, String body) async {
    final url = '$baseUrl/send-notification';
    try {
      final response = await _dio.post(
        url,
        data: {
          'token': token,
          'title': title,
          'body': body,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send notification');
      }
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  Future<List<dynamic>> getUnreadNotifications(String token) async {
    final url = '$baseUrl/notifications/$token';
    try {
      final response = await _dio.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch notifications');
      }

      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<void> markNotificationsAsRead(String token) async {
    final url = '$baseUrl/notifications/$token/read';
    try {
      final response = await _dio.post(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notifications as read');
      }
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
