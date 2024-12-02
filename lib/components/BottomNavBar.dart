import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _widgetOptions = <Widget>[
    AccueilPage(),
    CreateMatchPage(),
    UserProfilePage(),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    print('Tapped index: $index');
    setState(() {
      if (index == 2) {
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
    return Scaffold(
      key: _scaffoldKey,
      body: _widgetOptions[_selectedIndex],
      endDrawer: SideNav(onItemSelected: _onSideNavItemSelected),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.plusCircle),
            label: 'Créer',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bars),
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