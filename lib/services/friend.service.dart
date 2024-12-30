import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:teamup/services/auth.service.dart';
import '../utils/baseUrl.dart';

class FriendService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<void> sendFriendRequest(String receiverId) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final senderId = userInfo['id'];
    final token = userInfo['refresh_token'];

    try {
      final response = await _dio.post(
        '$baseUrl/friend/send',
        data: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send friend request');
      }
    } catch (e) {
      if (e is DioException &&
          e.response?.statusCode == 400 &&
          e.response?.data['error'] == 'friend request already exists') {
        throw Exception('Friend request already exists');
      }
      print('Error sending friend request: $e');
      throw Exception('Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _dio.post(
        '$baseUrl/friend/accept',
        data: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to accept friend request');
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      throw Exception('Failed to accept friend request: $e');
    }
  }

  Future<void> declineFriendRequest(String senderId) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final receiverId = userInfo['id'];
    final token = userInfo['refresh_token'];

    try {
      final response = await _dio.post(
        '$baseUrl/friend/decline',
        data: jsonEncode({
          'senderId': senderId,
          'receiverId': receiverId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to decline friend request');
      }
    } catch (e) {
      print('Error declining friend request: $e');
      throw Exception('Failed to decline friend request: $e');
    }
  }

  Future<List<dynamic>> getFriends() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final userId = userInfo['id'];
    final token = userInfo['refresh_token'];

    try {
      final response = await _dio.get(
        '$baseUrl/friend/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch friends');
      }

      return response.data;
    } catch (e) {
      print('Error fetching friends: $e');
      throw Exception('Failed to fetch friends: $e');
    }
  }

  Future<List<dynamic>> getFriendRequests() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final userId = userInfo['id'];
    final token = userInfo['refresh_token'];

    try {
      final response = await _dio.get(
        '$baseUrl/friend/requests/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch friend requests');
      }

      return response.data;
    } catch (e) {
      print('Error fetching friend requests: $e');
      throw Exception('Failed to fetch friend requests: $e');
    }
  }

  Future<List<dynamic>> searchUsersByUsername(String username) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) {
      throw Exception('User not logged in');
    }

    final token = userInfo['refresh_token'];

    try {
      final response = await _dio.get(
        '$baseUrl/friend/search',
        queryParameters: {'username': username},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to search users');
      }

      return response.data;
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }
}
