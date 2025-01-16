import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onNavigateDashboard;

  const Sidebar({
    required this.onLogout,
    required this.onNavigateDashboard,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.green[800],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/grey_logo.png',
                  height: 60,
                ),
                const SizedBox(height: 10),
                const Text(
                  'TeamUp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Analyste',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sports_soccer, color: Colors.white),
            title: const Text(
              'Gestion des matchs',
              style: TextStyle(color: Colors.white),
            ),
            onTap: onNavigateDashboard,
          ),
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
