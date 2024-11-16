import 'package:flutter/material.dart';
import '../services/auth.service.dart';

class SideNav extends StatefulWidget {
  final Function(int) onItemSelected;


  const SideNav({Key? key, required this.onItemSelected}) : super(key: key);

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
    setState(() {
      _username = userInfo?['username'];
      _email = userInfo?['email'];
    });
  }



  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              _username ?? "Nom d'utilisateur",
            ),
            accountEmail: Text(
              _email ?? "Email",
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "N",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF01BF6B),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.maps_home_work_rounded,
            ),
            title: const Text('Accueil',
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.create,
              color: Color(0xFF1867BA),
            ),
            title: const Text('Créer'),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle,
              color: Color(0xFFA1453C),
            ),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications,
              color: Color(0xFFD83F87),
            ),
            title: const Text('Notifications'),
            onTap: () {
              // Action for Menu
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings,
              color: Color(0xFFC19813),
            ),
            title: const Text('Paramètres'),
            onTap: () {
              // Action for Paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.help,
              color: Color(0xFF504BA3),
            ),
            title: const Text('Aide'),
            onTap: () {
              // Action for Aide
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () {
              AuthService().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}