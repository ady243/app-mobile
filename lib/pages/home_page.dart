import 'package:flutter/material.dart';
import 'package:teamup/components/BottomNavBar.dart';
import 'package:teamup/components/CustomAppBar.dart';
import 'package:teamup/pages/accueil_page.dart';
import 'package:teamup/pages/friend_page.dart';
import 'package:teamup/pages/match_create_page.dart';
import 'package:teamup/pages/chat_list_page.dart';
import 'package:teamup/pages/participate_match_page.dart';
import 'package:teamup/pages/profileScreen.dart';
import 'package:teamup/pages/setting_page.dart';
import '../components/SideNav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int _sideNavIndex = -1;

  static final List<Widget> _bottomNavOptions = <Widget>[
    const AccueilPage(),
    const FriendsPage(),
    const CreateMatchPage(),
    const ChatListPage(),
  ];

  static final List<Widget> _sideNavOptions = <Widget>[
    const UserProfilePage(),
    const SettingPage(),
    const ParticipatedMatchesPage(),
  ];

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _sideNavIndex = -1;
    });
  }

  void _onSideNavItemSelected(int index) {
    setState(() {
      _sideNavIndex = index;
      _selectedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _selectedIndex == 0
          ? null
          : CustomAppBar(
              title: _selectedIndex == 1
                  ? 'Amis'
                  : _selectedIndex == 2
                      ? 'Créer un Match'
                      : _selectedIndex == 3
                          ? 'Chats'
                          : _sideNavIndex == 0
                              ? 'Mon Profil'
                              : _sideNavIndex == 1
                                  ? 'Paramètres'
                                  : _sideNavIndex == 2
                                      ? 'Matchs Participés'
                                      : '',
              scaffoldKey: _scaffoldKey,
            ),
      drawer: SideNav(onItemSelected: _onSideNavItemSelected),
      body: _selectedIndex >= 0
          ? _bottomNavOptions[_selectedIndex]
          : _sideNavOptions[_sideNavIndex],
      bottomNavigationBar: BottomNavBar(
        onItemTapped: _onBottomNavItemTapped,
        selectedIndex: _selectedIndex >= 0 ? _selectedIndex : 0,
      ),
    );
  }
}
