import 'dart:convert';
import 'package:dio/dio.dart';

import 'auth.service.dart';

class MatchService {
  final String apiUrl = 'http://10.0.2.2:3003/api/matches';
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();

  Future<void> createMatch(Map<String, dynamic> matchData) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null || !userInfo.containsKey('id')) {
        throw Exception('Failed to retrieve user ID');
      }
      matchData['organizer_id'] = userInfo['id'];

      final response = await _dio.post(
        apiUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: json.encode(matchData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create match');
      }
    } catch (e) {
      print('Error creating match: $e');
      throw Exception('Failed to create match');
    }
  }

  Future<Map<String, dynamic>> getMatchWithPlayers(String matchId) async {
    try {
      final response = await _dio.get('$apiUrl/01JBFQAS1JKZ8R7P3KSKY3FM9Z');
      print(response.data.formations);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load match with players');
      }
    } catch (e) {
      print('Error fetching match with players: $e');
      throw Exception('Failed to load match with players');
    }
  }

  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        apiUrl,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load matches');
      }
    } catch (e) {
      print('Error fetching matches: $e');
      throw Exception('Failed to load matches');
    }
  }
}