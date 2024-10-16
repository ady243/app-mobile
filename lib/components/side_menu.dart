import 'package:flutter/material.dart';
import 'package:teamup/components/info_card.dart';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/services/auth.service.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int _activeIndex = 0;

  void _onMenuItemTap(int index) {
    setState(() {
      _activeIndex = index;
    });

    if (index == 5) {
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
        color: Colors.green[500],
        child: SafeArea(
          child: Column(
            children: [
              const InfoCard(),
              const SizedBox(height: 20, width: double.infinity,),

              _buildMenuItem(Icons.sports_soccer_rounded, 'Matches', 0),
              _buildMenuItem(Icons.favorite, 'Favoris', 1),
              _buildMenuItem(Icons.link, "Inviter", 2),
              _buildMenuItem(Icons.person_search, 'chercher', 3),
              const Spacer(),
              _buildMenuItem(Icons.settings, 'Paramètres', 4),
              _buildMenuItem(Icons.exit_to_app, 'Déconnexion', 5),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
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
    );
  }
}