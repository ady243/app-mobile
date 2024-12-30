import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/baseUrl.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  AuthService() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await _storage.read(key: 'accessToken');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            await _refreshToken();
            _isRefreshing = false;
            handler.resolve(await _retry(error.requestOptions));
          } catch (e) {
            _isRefreshing = false;
            await logout();
            handler.next(error);
          }
        } else {
          return handler.next(error);
        }
      },
    ));
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '$baseUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 &&
          response.data['accessToken'] != null &&
          response.data['refreshToken'] != null) {
        await _storage.write(
            key: 'accessToken', value: response.data['accessToken']);
        await _storage.write(
            key: 'refreshToken', value: response.data['refreshToken']);
      } else {
        throw Exception('Erreur lors du rafraîchissement du token.');
      }
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 &&
          response.data['accessToken'] != null &&
          response.data['refreshToken'] != null) {
        await _storage.write(
            key: 'accessToken', value: response.data['accessToken']);
        await _storage.write(
            key: 'refreshToken', value: response.data['refreshToken']);
      } else {
        throw Exception('Erreur lors de la connexion : token non fourni.');
      }
    } catch (e) {
      if (e is DioError) {
      } else {}
      rethrow;
    }
  }

  Future<bool> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '$baseUrl/auth/google/callback',
        data: jsonEncode({'idToken': idToken}),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 &&
          response.data['accessToken'] != null &&
          response.data['refreshToken'] != null) {
        await _storage.write(
            key: 'accessToken', value: response.data['accessToken']);
        await _storage.write(
            key: 'refreshToken', value: response.data['refreshToken']);
        return true;
      } else {
        throw Exception('Erreur lors de la connexion avec Google.');
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'inscription.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    const int maxRetries = 3;
    int retryCount = 0;
    int delay = 1;

    while (retryCount < maxRetries) {
      try {
        if (await isLoggedIn()) {
          final response = await _dio.get('$baseUrl/userInfo');

          if (response.statusCode == 200) {
            return response.data;
          } else if (response.statusCode == 429) {
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(Duration(seconds: delay));
              delay *= 2;
            } else {
              throw Exception('Rate limit exceeded. Please try again later.');
            }
          } else {
            throw Exception(
                'Erreur lors de la récupération des informations utilisateur');
          }
        } else {
          throw Exception('User not logged in.');
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserInfoById(String userId) async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      final response = await _dio.get(
        '$baseUrl/users/$userId/public',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Erreur lors de la récupération des détails de l\'utilisateur');
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '$baseUrl/userUpdate',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Erreur lors de la mise à jour des informations utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      return accessToken != null;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'accessToken');
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _dio.delete('$baseUrl/deleteMyAccount');
      if (response.statusCode == 200) {
        await logout();
      } else {
        throw Exception(
            'Erreur lors de la suppression du compte utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      final response = await _dio.get(
        '$baseUrl/users',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la récupération des utilisateurs.');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }
}
