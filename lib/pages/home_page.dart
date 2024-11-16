import 'package:flutter/material.dart';
import '../components/BottomNavBar.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: const Scaffold(
              bottomNavigationBar: BottomNavBar(),
            ),
          ),

        ],
      ),
    );
  }
}
