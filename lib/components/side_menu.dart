import 'package:flutter/material.dart';
import 'package:teamup/components/info_card.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: Colors.green[500],
        child: SafeArea(
          child: Column(
            children: [
              const InfoCard(),

              const SizedBox(height: 20),
              Divider(color: Colors.green[700]),
              _buildMenuItem(Icons.settings, 'Paramètres', 0),
              _buildMenuItem(Icons.home, 'Accueil', 1),
              _buildMenuItem(Icons.favorite, 'Favoris', 2),
              _buildMenuItem(Icons.person, 'Profil', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    bool isActive = _activeIndex == index;

    return GestureDetector(
      onTap: () => _onMenuItemTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        color: isActive ? Colors.green[700] : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white70),
            const SizedBox(width: 5),
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
