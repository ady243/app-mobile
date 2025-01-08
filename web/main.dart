import 'package:flutter/material.dart';
import 'backoffice/login_page_analyst.dart';
import 'backoffice/analyst_dashboard_page.dart';
import 'backoffice/event_management_page.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
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
    ),
    initialRoute: '/loginAnalyst',
    routes: {
      '/loginAnalyst': (context) => const LoginPageAnalyst(),
      '/analystDashboard': (context) => AuthGuard(
        builder: (_) => const AnalystDashboardPage(),
      ),
      '/eventManagement': (context) => AuthGuard(
        builder: (context) {
          final matchId = ModalRoute.of(context)!.settings.arguments as String? ?? '';
          if (matchId.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Gestion des événements')),
              body: const Center(child: Text('Aucun match sélectionné.')),
            );
          }
          return EventManagementPage(matchId: matchId);
        },
      ),
    },
  ));
}
