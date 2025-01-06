import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth.service.dart';
import 'package:provider/provider.dart';
import '../components/theme_provider.dart';

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
    widget.onItemSelected(index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_username ?? ""),
            accountEmail: Text(_email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (_username != null && _username!.length >= 2)
                    ? _username!.substring(0, 2)
                    : '',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: themeProvider.primaryColor,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(FontAwesomeIcons.home, 'Accueil', Colors.blue,
                    () => _onItemTap(0)),
                _buildListTile(FontAwesomeIcons.userFriends, 'Amis',
                    Colors.green, () => _onItemTap(1)),
                _buildListTile(FontAwesomeIcons.plusCircle, 'Créer',
                    Colors.orange, () => _onItemTap(2)),
                _buildListTile(FontAwesomeIcons.comments, 'Chat', Colors.pink,
                    () => _onItemTap(3)),
                _buildListTile(FontAwesomeIcons.cog, 'Paramètres',
                    Colors.purple, () => _onItemTap(5)),
                _buildListTile(
                    FontAwesomeIcons.bell, 'Notification', Colors.teal, () {
                  _onItemTap(4);
                }),
                _buildListTile(
                    FontAwesomeIcons.signOutAlt, 'Se déconnecter', Colors.brown,
                    () {
                  AuthService().logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildListTile(
      IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: onTap,
    );
  }
}
