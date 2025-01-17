import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Function onLogout;
  final Function onNavigateDashboard;
  final List<Widget>? extraItems;

  const Sidebar({
    required this.onLogout,
    required this.onNavigateDashboard,
    this.extraItems,
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
            decoration: BoxDecoration(
              color: Colors.green[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/grey_logo.png',
                  height: 150,
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
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => onNavigateDashboard(),
          ),
          const Divider(color: Colors.white54),
          if (extraItems != null) ...extraItems!,
          const Divider(color: Colors.white54),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => onLogout(),
          ),
        ],
      ),
    );
  }
}
