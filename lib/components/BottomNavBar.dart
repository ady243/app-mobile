import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teamup/pages/friend_page.dart';
import '../pages/accueil_page.dart';
import '../pages/match_create_page.dart';
import '../pages/profileScreen.dart';
import '../pages/setting_page.dart';
import '../pages/chat_list_page.dart';
import '../pages/notification_page.dart';
import '../pages/user_profile.dart';
import 'SideNav.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:teamup/services/notification_service.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  bool _hasUnreadNotifications = false;
  bool _hasUnreadMessages = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<Widget> _widgetOptions = <Widget>[
    const UserProfilePage(),
    const AccueilPage(),
    const FriendsPage(),
    const CreateMatchPage(),
    const ChatListPage(),
    const NotificationPage(),
    const SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _checkUnreadNotifications();
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        if (message.data['type'] == 'new_message') {
          _hasUnreadMessages = true;
        } else {
          _hasUnreadNotifications = true;
        }
      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      setState(() {
        if (message.data['type'] == 'new_message') {
          _hasUnreadMessages = true;
        } else {
          _hasUnreadNotifications = true;
        }
      });
    });
  }

  Future<void> _checkUnreadNotifications() async {
    final notificationService =
    Provider.of<NotificationService>(context, listen: false);
    final token = await notificationService.getToken();
    if (token != null) {
      final notifications =
      await notificationService.getUnreadNotifications(token);
      setState(() {
        _hasUnreadNotifications = notifications.isNotEmpty;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 5) {
        _scaffoldKey.currentState?.openEndDrawer();
      } else {
        _selectedIndex = index;
        if (index == 4) {
          _hasUnreadNotifications = false;
          _markNotificationsAsRead();
        }
        if (index == 3) {
          _hasUnreadMessages = false;
        }
      }
    });
  }

  Future<void> _markNotificationsAsRead() async {
    final notificationService =
    Provider.of<NotificationService>(context, listen: false);
    final token = await notificationService.getToken();
    if (token != null) {
      await notificationService.markNotificationsAsRead(token);
    }
  }

  void _onSideNavItemSelected(int index) {
    setState(() {
      if (index < _widgetOptions.length) {
        _selectedIndex = index;
      } else {
        // Handle the case where the index is out of range
        // For example, you can navigate to a different page or show an error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: _widgetOptions[_selectedIndex],
      endDrawer: SideNav(onItemSelected: _onSideNavItemSelected),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home, color: themeProvider.iconColor),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userFriends,
                color: themeProvider.iconColor),
            label: 'Amis',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.futbol,
                color: themeProvider.iconColor),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                FaIcon(FontAwesomeIcons.comments,
                    color: themeProvider.iconColor),
                if (_hasUnreadMessages)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                FaIcon(FontAwesomeIcons.bell, color: themeProvider.iconColor),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bars, color: themeProvider.iconColor),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: themeProvider.selectedLabelColor,
        unselectedItemColor: themeProvider.unselectedLabelColor,
        selectedLabelStyle: TextStyle(
          color: themeProvider.selectedLabelColor,
        ),
        unselectedLabelStyle: TextStyle(
          color: themeProvider.unselectedLabelColor,
        ),
        onTap: _onItemTapped,
      ),
    );
  }
}