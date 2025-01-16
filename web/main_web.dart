import 'package:flutter/material.dart';
import 'backoffice/login_page_analyst.dart';
import 'backoffice/analyst_dashboard_page.dart';
import 'backoffice/event_management_page.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/loginAnalyst',
      routes: {
        '/loginAnalyst': (context) => const LoginPageAnalyst(),
        '/analystDashboard': (context) => AuthGuard(
          builder: (_) => const AnalystDashboardPage(),
        ),
      },
      onGenerateRoute: _generateRoute,
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
      ).copyWith(
        secondary: Colors.greenAccent,
      ),
      scaffoldBackgroundColor: Colors.grey[200],
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Route? _generateRoute(RouteSettings settings) {
    if (settings.name!.startsWith('/eventManagement/')) {
      final matchId = settings.name!.split('/').last;
      return MaterialPageRoute(
        builder: (context) => AuthGuard(
          builder: (_) => EventManagementPage(matchId: matchId),
        ),
      );
    }

    // Route inconnues
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('404: Page Not Found\nRoute: ${settings.name}'),
        ),
      ),
    );
  }
}
