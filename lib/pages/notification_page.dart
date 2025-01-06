import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/pages/MatchDetailsPage.dart';
import 'package:teamup/pages/chat_page.dart';
import 'package:teamup/pages/friends_tab_page.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final message =
        ModalRoute.of(context)!.settings.arguments as RemoteMessage?;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (message == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: themeProvider.primaryColor,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Container(
              color: themeProvider.primaryColor,
              padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: const Text('Aucune notification disponible'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.primaryColor,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Container(
            color: themeProvider.primaryColor,
            padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Text(message.notification?.title ?? 'Pas de titre'),
          Text(message.notification?.body ?? 'Pas de corps'),
          Text(message.data.toString()),
          ElevatedButton(
            onPressed: () {
              _handleNotificationClick(message);
            },
            child: const Text('Voir'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    if (message.data['type'] == 'new_message') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            friendName: message.data['friendName'],
            senderId: message.data['senderId'],
            receiverId: message.data['receiverId'],
            receiverFcmToken: message.data['receiverFcmToken'],
          ),
        ),
      );
    } else if (message.data['type'] == 'friend_request') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FriendsTabPage(),
        ),
      );
    } else if (message.data['type'] == 'match_update') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchDetailsPage(
            matchId: message.data['matchId'],
          ),
        ),
      );
    }
  }
}
