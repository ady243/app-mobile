import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/pages/signup_page.dart';
import 'package:teamup/entry/entry_point.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => const MyApp(),
    // ),
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    initUniLinks();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _checkLoginStatus() async {
    bool loggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  void initUniLinks() async {
    try {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          Navigator.pushNamed(context, '/login', arguments: uri.queryParameters);
        }
      }, onError: (err) {
      print('Failed to get the initial link: $err');
      });
    } catch (e) {
      print('Failed to get the initial link: $e');
    }
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      Navigator.pushNamed(context, '/login', arguments: initialUri.queryParameters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const EntryPoint(),
      },
    );
  }
}