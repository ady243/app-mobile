import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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
        if (error.response?.statusCode == 401) {
          await logout();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'http://127.0.0.1:3003/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['accessToken'] != null) {
        await _storage.write(key: 'accessToken', value: response.data['accessToken']);
      } else {
        throw Exception('Erreur lors de la connexion : token non fourni.');
      }
    } catch (e) {
      if (e is DioError) {
        print('Erreur de connexion: ${e.response?.data}');
      } else {
        print('Erreur inattendue: $e');
      }
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
       // 'http://127.0.0.1:3003/api/register',
        'http://127.0.0.1:3003/api/login',
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
      print('Erreur d\'inscription: $e');
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
          final response = await _dio.get('http://127.0.0.1:3003/api/userinfo');

          if (response.statusCode == 200) {
            return response.data;
          } else if (response.statusCode == 429) {
            retryCount++;
            if (retryCount < maxRetries) {
              print('Rate limit exceeded. Retrying in $delay seconds...');
              await Future.delayed(Duration(seconds: delay));
              delay *= 2;
            } else {
              print('Max retries reached. Rate limit exceeded.');
              throw Exception('Rate limit exceeded. Please try again later.');
            }
          } else {
            throw Exception('Error retrieving user info: ${response.statusCode}');
          }
        } else {
          throw Exception('User not logged in.');
        }
      } catch (e) {
        print('Error retrieving user info: $e');
        return null;
      }
    }
    return null;
  }


  Future<Map<String, dynamic>?> updateUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
      //'http://10.0.2.2:3003/api/userUpdate',
        'http://127.0.0.1:3003/api/userUpdate',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la mise à jour des informations utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'accessToken');
      print('Déconnexion réussie.');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      return accessToken != null;
    } catch (e) {
      print('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'accessToken');
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }
}
