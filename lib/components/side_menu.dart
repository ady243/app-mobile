import 'package:flutter/material.dart';
import 'package:teamup/components/info_card.dart';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/services/auth.service.dart';

import '../pages/profileScreen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final logout = AuthService().logout;
  int _activeIndex = 0;
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    setState(() {
      _username = userInfo?['username'];
    });
  }

  void _onMenuItemTap(int index) {
    setState(() {
      _activeIndex = index;
    });

    if (index == 3) {
      logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1000,
        color: Color(0xFF01BF6B),
        child: SafeArea(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserProfilePage()),
                  );
                },
                child: const InfoCard(),
              ),
              if (_username != null)
                const SizedBox(height: 20, width: double.infinity),
              _buildMenuItem(Icons.sports_soccer_rounded, 'Matches', 0),
              _buildMenuItem(Icons.link, "Inviter", 1),
              const Spacer(),
              _buildMenuItem(Icons.exit_to_app, 'Déconnexion', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    bool isActive = _activeIndex == index;

    return InkWell(
      onTap: () => _onMenuItemTap(index),
      child: Ink(
        color: isActive ? Colors.black26 : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.white70),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}