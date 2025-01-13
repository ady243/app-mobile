import 'package:flutter/material.dart';
import 'package:teamup/components/FriendsTabComponent.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: const FriendsTabComponent(),
    );
  }
}