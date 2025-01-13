import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(int index) {
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.home, color: themeProvider.iconColor),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.userFriends,
              color: themeProvider.iconColor),
          label: 'Amis',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.futbol, color: themeProvider.iconColor),
          label: 'Match',
        ),
        BottomNavigationBarItem(
          icon:
              FaIcon(FontAwesomeIcons.comments, color: themeProvider.iconColor),
          label: 'Chat',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: themeProvider.selectedLabelColor,
      unselectedItemColor: themeProvider.unselectedLabelColor,
      selectedLabelStyle: TextStyle(
        color: themeProvider.selectedLabelColor,
      ),
      unselectedLabelStyle: TextStyle(
        color: themeProvider.unselectedLabelColor,
      ),
      onTap: _onItemTapped,
    );
  }
}