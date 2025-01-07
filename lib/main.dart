import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/auth.service.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'UserProvider/user_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseApi().initNotifications();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr', 'FR'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MyApp(),
      ),
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
    print('initState called');
    _checkLoginStatus();
    initUniLinks();
    _setupFirebaseMessaging();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
    print('dispose called');
  }

  void _checkLoginStatus() async {
    print('Checking login status...');
    bool loggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      print('Login status: $_isLoggedIn');
    });
  }

  void initUniLinks() async {
    print('Initializing UniLinks...');
    try {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print('Received URI: $uri');
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        print('Error listening to URI stream: $err');
      });
    } catch (e) {
      print('Exception in initUniLinks: $e');
    }
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      print('Initial URI: $initialUri');
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Handling deep link: $uri');
    if (uri.path == '/api/confirm_email') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        print('Email confirmation token: $token');
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  void _setupFirebaseMessaging() {
    print('Setting up Firebase Messaging...');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.messageId}');
      if (message.notification != null) {
        _showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.messageId}');
      _handleNotificationClick(message);
    });
  }

  void _showNotification(RemoteMessage message) {
    print('Showing notification: ${message.notification?.title}');
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: Text(message.notification?.title ?? tr('notification')),
        content: Text(message.notification?.body ?? tr('new_notification')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleNotificationClick(message);
            },
            child: Text(tr('view')),
          ),
        ],
      ),
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    print('Handling notification click: ${message.messageId}');
    navigatorKey.currentState?.pushNamed(
      '/notification',
      arguments: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building MyApp');
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        builder: DevicePreview.appBuilder,
        theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        initialRoute: _isLoggedIn ? '/home' : '/login',
        navigatorKey: navigatorKey,
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const EntryPoint(),
          '/notification': (context) => const NotificationPage(),
        },
      ),
    );
  }
}