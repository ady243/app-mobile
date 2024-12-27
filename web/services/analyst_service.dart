import 'dart:convert';
import 'package:dio/dio.dart';
import '../../lib/utils/basUrl.dart';

class AnalystService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> getEventsByMatch(String matchId) async {
    final response = await _dio.get('$baseUrl/events/match/$matchId');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _dio.post('$baseUrl/events', data: eventData);
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> updatedData) async {
    await _dio.put('$baseUrl/events/$eventId', data: updatedData);
  }

  Future<void> deleteEvent(String eventId) async {
    await _dio.delete('$baseUrl/events/$eventId');
  }
}
