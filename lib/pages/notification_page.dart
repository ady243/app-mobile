import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/ChatTab.dart';
import 'package:teamup/pages/MatchDetailsPage.dart';
import 'package:teamup/pages/friends_tab_page.dart';
import 'package:teamup/services/notification_service.dart';
import 'package:teamup/components/theme_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notificationService =
        Provider.of<NotificationService>(context, listen: false);
    final token = await notificationService.getToken();
    if (token != null) {
      final notifications =
          await notificationService.getUnreadNotifications(token);
      setState(() {
        _notifications = notifications;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
      body: _notifications.isEmpty
          ? const Center(
              child: Text('Aucune notification disponible'),
            )
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return ListTile(
                  title: Text(notification['title'] ?? 'Pas de titre'),
                  subtitle: Text(notification['body'] ?? 'Pas de corps'),
                  onTap: () {
                    _handleNotificationClick(notification);
                  },
                );
              },
            ),
    );
  }

  void _handleNotificationClick(dynamic notification) {
    if (notification['type'] == 'new_message') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatTab(matchId: notification['matchId']),
        ),
      );
    } else if (notification['type'] == 'friend_request') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FriendsTabPage(),
        ),
      );
    } else if (notification['type'] == 'match_update') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchDetailsPage(
            matchId: notification['matchId'],
          ),
        ),
      );
    }
  }
}
