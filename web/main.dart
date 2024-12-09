import 'package:flutter/material.dart';
import 'backoffice/login_page.dart';
import 'backoffice/referee_dashboard_page.dart';
import 'backoffice/match_detail_page.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/refereeDashboard': (context) => RefereeDashboardPage(),
      '/matchDetail': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        final matchId = args['matchId'] as String;
        return MatchDetailPage(matchId: matchId);
      },
    },
  ));
}
