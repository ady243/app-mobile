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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';

import 'UserProvider/user_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation d'EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseApi().initNotifications();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
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
    _checkLoginStatus();
    initUniLinks();
    _setupFirebaseMessaging();
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
      }, onError: (err) {});
    } catch (e) {}
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/api/confirm_email') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        Navigator.pushNamed(context, '/home');
      }
    }
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {}
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      final friendName = message.data['friendName'];
      final senderId = message.data['senderId'];
      final receiverId = message.data['receiverId'];
      final receiverFcmToken = message.data['receiverFcmToken'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            friendName: friendName,
            senderId: senderId,
            receiverId: receiverId,
            receiverFcmToken: receiverFcmToken,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: context.locale,
        builder: DevicePreview.appBuilder,
        theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
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
