import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teamup/constant/constants.dart';

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
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
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


  // Méthode pour se connecter
  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'http://localhost:3003/api/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['accessToken'] != null) {
        await _storage.write(key: 'accessToken', value: response.data['accessToken']);
      }
       else {
        throw Exception('Erreur lors de la connexion : token non fourni.');
      }} catch (e) {
      if (e is DioError) {
        print('Erreur de connexion: ${e.response?.data}');
      } else {
        print('Erreur inattendue: $e');
      }
      rethrow;
    }


  }

  // Méthode pour s'enregistrer
  Future<void> register(String username, String email, String password) async {
    try {
      final response = await _dio.post(
        'http://localhost:3003/api/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Vérification de la validité de la réponse
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'inscription.');
      }
    } catch (e) {
      print('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  // Méthode pour se déconnecter
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'token');
      print('Déconnexion réussie.');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'token');
      return token != null;
    } catch (e) {
      print('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  // Récupérer le token (facultatif)
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }
}
