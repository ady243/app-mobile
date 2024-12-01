import 'package:flutter/material.dart';
import '../pages/accueil_page.dart';
import '../pages/match_create_page.dart';
import '../pages/profileScreen.dart';
import '../pages/setting_page.dart';
import 'SideNav.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0; // Index initial
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _widgetOptions = <Widget>[
    AccueilPage(),
    CreateMatchPage(),
    UserProfilePage(), // Ajouté pour la navigation via SideNav
    SettingPage(), // Ajouté pour la navigation via SideNav
  ];

  void _onItemTapped(int index) {
    print('Tapped index: $index'); // Debugging log
    setState(() {
      if (index == 2) {
        // Ouvre le SideNav
        _scaffoldKey.currentState?.openEndDrawer();
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _onSideNavItemSelected(int index) {
    print('SideNav selected index: $index'); // Debugging log
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _widgetOptions[_selectedIndex],
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
            icon: Icon(Icons.menu_rounded),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex < 2 ? _selectedIndex : 0,
        selectedItemColor: const Color(0xFF01BF6B),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}