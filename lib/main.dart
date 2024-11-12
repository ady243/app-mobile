import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teamup/entry/entry_point.dart';
import 'package:teamup/pages/login_page.dart';
import 'package:teamup/pages/signup_page.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization
import '../pages/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('fr', 'FR')],
      path: 'lang', // Dossier où se trouvent les fichiers JSON
      fallbackLocale: Locale('en', 'US'), // Langue par défaut
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const MyApp(),
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool loggedIn = await AuthService().isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: context.locale, // Définir la locale avec easy_localization
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      builder: DevicePreview.appBuilder,
      initialRoute: _isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const EntryPoint(),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
