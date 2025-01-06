import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:teamup/main.dart';
import 'package:teamup/pages/chat_page.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> retrieveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
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

    if (message.data['type'] == 'new_message') {
      final senderId = message.data['senderID'];
      final receiverId = message.data['receiverID'];
      final content = message.data['content'];
      final friendName = message.data['friendName'];
      final receiverFcmToken = message.data['receiverFcmToken'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            friendName: friendName,
            senderId: receiverId,
            receiverId: senderId,
            receiverFcmToken: receiverFcmToken,
          ),
        ),
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