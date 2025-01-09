import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teamup/main.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> retrieveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      if (token != null) {
        await _storage.write(key: 'fcmToken', value: token);
      }
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token FCM: $e');
      return null;
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await retrieveFCMToken();
    print('FCM Token: $fcmToken');

    initPushNotification();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    if (message.data['type'] == 'new_message' ||
        message.data['type'] == 'friend_request' ||
        message.data['type'] == 'match_update') {
      navigatorKey.currentState?.pushNamed(
        '/notification',
        arguments: message,
      );
    }
  }

  Future<void> initPushNotification() async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((message) => handleMessage(message));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}