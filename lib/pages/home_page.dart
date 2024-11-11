import 'package:flutter/material.dart';
import 'package:teamup/components/side_menu.dart';
import '../components/BottomNavBar.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSideBarClosed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSideBarClosed ? Colors.white : Colors.green,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 900),
            curve: Curves.fastOutSlowIn,
            width: 200,
            left: isSideBarClosed ? -258 : 0,
            height: MediaQuery.of(context).size.height,
            child: const SideMenu(),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.fastOutSlowIn,
            transform: Matrix4.translationValues(isSideBarClosed ? 0 : 288, 0, 0),
            decoration: BoxDecoration(
              borderRadius: isSideBarClosed
                  ? const BorderRadius.all(Radius.circular(24))
                  : BorderRadius.zero,
            ),
            child: const Scaffold(
              body: Center(
                child: Text("Welcome to Home Page!!!"),
              ),
              bottomNavigationBar: BottomNavBar(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInCirc,
            left: isSideBarClosed ? 16 : MediaQuery.of(context).size.width - 160,
            top: 12,
            child: IconButton(
              icon: Icon(isSideBarClosed ? Icons.menu : Icons.close),
              onPressed: () {
                setState(() {
                  isSideBarClosed = !isSideBarClosed;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
