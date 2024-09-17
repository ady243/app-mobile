import 'package:flutter/material.dart';
import 'package:teamup/components/side_menu.dart';
import 'package:teamup/pages/profileScreen.dart';
import '../models/menu_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              child: Profile(),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInCirc,
            left: isSideBarClosed ? 16 : MediaQuery.of(context).size.width - 160,
            top: 12,
            child: MenuBtn(
              press: () {
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