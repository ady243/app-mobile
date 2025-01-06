import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/pages/chat_page.dart';
import 'package:teamup/pages/notification_page.dart';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/pages/signup_page.dart';
import 'package:teamup/entry/entry_point.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teamup/firebase_options.dart';
import 'package:teamup/api/firebase_api.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';
import 'package:uni_links/uni_links.dart';

import 'UserProvider/user_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
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
        print('Email confirmé avec le token: $token');
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('fr', 'FR'),
        ],
        initialRoute: _isLoggedIn ? '/home' : '/login',
        navigatorKey: navigatorKey,
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const EntryPoint(),
          '/notification': (context) => const NotificationPage(),
          '/chat': (context) => ChatPage(
            friendName: '',
            senderId: '',
            receiverId: '',
            receiverFcmToken: '',
          ),
        },
      ),
    );
  }
}