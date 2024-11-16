// lib/components/BottomNavBar.dart
import 'package:flutter/material.dart';
import '../pages/accueil_page.dart';
import '../pages/match_create_page.dart';
import '../pages/profileScreen.dart';
import 'SideNav.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _widgetOptions = <Widget>[
    AccueilPage(),
    CreateMatchPage(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _onSideNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _widgetOptions.elementAt(_selectedIndex),
      endDrawer: SideNav(onItemSelected: _onSideNavItemSelected),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.maps_home_work_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Créer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded),
            label: 'Menu',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF01BF6B),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}