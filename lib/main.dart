// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/pages/signup_page.dart';
import 'package:teamup/entry/entry_point.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:device_preview/device_preview.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'components/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        print('Failed to get the initial link: $err');
      });
    } catch (e) {
      print('Failed to get the initial link: $e');
    }
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/api/confirm_email') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        print('Email confirmed with token: $token');
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const EntryPoint(),
      },
    );
  }
}