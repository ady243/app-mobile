import 'dart:convert';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import '../utils/baseUrl.dart';

class AuthWebService {
  final Dio _dio = Dio();
  bool _isRefreshing = false;

  AuthWebService() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = _getAccessToken();
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

  /// Récupère le token d'accès depuis le stockage local
  String? _getAccessToken() {
    return html.window.localStorage['accessToken'];
  }

  /// Stocke les tokens dans le stockage local
  Future<void> _storeTokens(String accessToken, String refreshToken) async {
    html.window.localStorage['accessToken'] = accessToken;
    html.window.localStorage['refreshToken'] = refreshToken;
  }

  /// Supprime les tokens du stockage local
  Future<void> _clearTokens() async {
    html.window.localStorage.remove('accessToken');
    html.window.localStorage.remove('refreshToken');
  }

  /// Rafraîchit le token d'accès
  Future<void> _refreshToken() async {
    try {
      final refreshToken = html.window.localStorage['refreshToken'];
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
        await _storeTokens(
          response.data['accessToken'],
          response.data['refreshToken'],
        );
      } else {
        throw Exception('Erreur lors du rafraîchissement du token.');
      }
    } catch (e) {
      await logout();
      rethrow;
    }
  }

  /// Réessaie une requête après avoir rafraîchi le token
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

  /// Authentification de l'utilisateur
  Future<void> login(String email, String password) async {
    try {
      print('Tentative de connexion avec : $email');

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
        await _storeTokens(
          response.data['accessToken'],
          response.data['refreshToken'],
        );
      } else {
        throw Exception('Erreur lors de la connexion : token non fourni.');
      }
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      rethrow;
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    await _clearTokens();
  }

  /// Vérifie si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final accessToken = _getAccessToken();
    return accessToken != null;
  }

  /// Récupère les informations utilisateur
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      if (await isLoggedIn()) {
        final response = await _dio.get('$baseUrl/userInfo');
        if (response.statusCode == 200) {
          return response.data;
        } else {
          throw Exception('Erreur lors de la récupération des informations utilisateur');
        }
      } else {
        throw Exception('Utilisateur non connecté.');
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur : $e');
      return null;
    }
  }

  /// Récupère un token d'accès
  Future<String?> getToken() async {
    try {
      return _getAccessToken();
    } catch (e) {
      print('Erreur lors de la récupération du token : $e');
      return null;
    }
  }

  /// Met à jour les informations utilisateur
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
      print('Erreur lors de la mise à jour des informations utilisateur : $e');
      return null;
    }
  }

  /// Supprime le compte utilisateur
  Future<void> deleteAccount() async {
    try {
      final accessToken = _getAccessToken();
      final response = await _dio.delete(
        '$baseUrl/deleteMyAccount',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response.statusCode == 200) {
        await logout();
      } else {
        throw Exception(
            'Erreur lors de la suppression du compte utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la suppression du compte utilisateur : $e');
      rethrow;
    }
  }
}
