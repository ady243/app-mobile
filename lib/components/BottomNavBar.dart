import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teamup/pages/friend_page.dart';
import '../pages/accueil_page.dart';
import '../pages/match_create_page.dart';
import '../pages/profileScreen.dart';
import '../pages/setting_page.dart';
import '../pages/chat_list_page.dart';
import '../pages/notification_page.dart'; // Import de la page de notification
import 'SideNav.dart';
import '../components/theme_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final List<Widget> _widgetOptions = <Widget>[
    const AccueilPage(),
    const FriendsPage(),
    const CreateMatchPage(),
    const ChatListPage(),
    const NotificationPage(), // Ajout de la page de notification
    const SettingPage(), // Ajout de la page de paramètres
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (index == 5) {
        _scaffoldKey.currentState?.openEndDrawer();
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _onSideNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
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
            icon: FaIcon(FontAwesomeIcons.plusCircle,
                color: themeProvider.iconColor),
            label: 'Créer',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.comments,
                color: themeProvider.iconColor),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bell, color: themeProvider.iconColor),
            label:
                'Notification', // Ajout de l'élément de navigation pour les notifications
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
