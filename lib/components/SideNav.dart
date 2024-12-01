import 'package:flutter/material.dart';
import '../services/auth.service.dart';

class SideNav extends StatefulWidget {
  final Function(int) onItemSelected;

  const SideNav({super.key, required this.onItemSelected});

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  String? _username;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    if (mounted) {
      setState(() {
        _username = userInfo?['username'];
        _email = userInfo?['email'];
      });
    }
  }

  void _onItemTap(int index) {
    print('SideNav item tapped: $index'); // Debugging log
    widget.onItemSelected(index);
    Navigator.pop(context);  // Close the side nav after selection
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_username ?? "Nom d'utilisateur"),
            accountEmail: Text(_email ?? "Email"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (_username != null && _username!.length >= 2)
                    ? _username!.substring(0, 2)
                    : 'U',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF01BF6B),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(Icons.maps_home_work_rounded, 'Accueil', () => _onItemTap(0)),
                _buildListTile(Icons.create, 'Créer', () => _onItemTap(1)),
                _buildListTile(Icons.account_circle, 'Profil', () => _onItemTap(2)),
                _buildListTile(Icons.notifications, 'Notifications', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications en cours de développement')),
                  );
                }),
                _buildListTile(Icons.settings, 'Paramètres', () => _onItemTap(3)),
                _buildListTile(Icons.help, 'Aide', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Aide en cours de développement')),
                  );
                }),
                _buildListTile(Icons.logout, 'Se déconnecter', () {
                  AuthService().logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}