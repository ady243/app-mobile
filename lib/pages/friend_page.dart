import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/FriendsTabPage.dart';
import 'package:teamup/components/theme_provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
      ),
      body: const FriendsTabPage(),
    );
  }
}
