import 'package:flutter/material.dart';
import 'package:teamup/components/side_menu.dart';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/pages/home_page.dart';
import '../models/menu_btn.dart';
import '../services/auth.service.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({Key? key}) : super(key: key);

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool isSideBarClosed = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool loggedIn = await AuthService().isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSideBarClosed ? Colors.white : Color(0xFF01BF6B),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          // Side menu
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
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              child: isLoggedIn ? HomePage() : const LoginPage(),
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
