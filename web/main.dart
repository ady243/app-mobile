import 'package:flutter/material.dart';
import 'backoffice/login_page_analyst.dart';
import 'backoffice/analyst_dashboard_page.dart';
import 'backoffice/match_detail_page.dart';
import 'backoffice/event_management_page.dart';
import 'services/authweb_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authWebService = AuthWebService();
  String initialRoute = await authWebService.isLoggedIn()
      ? '/analystDashboard'
      : '/loginAnalyst';

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
    initialRoute: initialRoute,
    routes: {
      '/loginAnalyst': (context) => LoginPageAnalyst(),
      '/analystDashboard': (context) => AnalystDashboardPage(),
      '/eventManagement': (context) {
        final matchId = ModalRoute.of(context)!.settings.arguments as String?;
        if (matchId == null || matchId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gestion des événements')),
            body: const Center(
              child: Text('Aucun match sélectionné.'),
            ),
          );
        }
        return EventManagementPage(matchId: matchId);
      },
      '/matchDetail': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final matchId = args['matchId'] as String;
        return MatchDetailPage(matchId: matchId);
      },
    },
  ));
}
