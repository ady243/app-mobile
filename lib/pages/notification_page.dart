import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:teamup/pages/chat_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Page'),
      ),
      body: Column(
        children: [
          Text(message.notification!.title.toString()),
          Text(message.notification!.body.toString()),
          Text(message.data.toString()),
          ElevatedButton(
            onPressed: () {
              if (message.data['type'] == 'message') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      friendName: message.data['username'],
                      senderId: message.data['receiver_id'],
                      receiverId: message.data['sender_id'],
                      receiverFcmToken: message.data['receiver_fcm_token'],
                    ),
                  ),
                );
              }
            },
            child: const Text('Voir le message'),
          ),
        ],
      ),
    );
  }
}