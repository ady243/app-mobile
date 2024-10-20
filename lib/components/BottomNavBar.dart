import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

import '../pages/chats_screen.dart';
import '../pages/match_create_page.dart';
import '../pages/profileScreen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text(
        'Accueil',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurpleAccent,
        ),

      ),

    ),
    UserProfilePage(),
    CreateMatchPage(),
    ChatsScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Accueil", "Profil", "Créer", "Messages"],
        initialSelectedTab: "Accueil",
        tabIconColor: Colors.black,
        tabSelectedColor:  Color(0xFF01BF6B),
        icons: const [Icons.home, Icons.person, Icons.add, Icons.message],
        textStyle: const TextStyle(color: Colors.black),
        onTabItemSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
