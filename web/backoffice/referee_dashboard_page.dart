import 'package:flutter/material.dart';
import 'package:teamup/services/auth.service.dart';
import '../services/match_service.dart';

class RefereeDashboardPage extends StatefulWidget {
  const RefereeDashboardPage({super.key});

  @override
  State<RefereeDashboardPage> createState() => _RefereeDashboardPageState();
}

class _RefereeDashboardPageState extends State<RefereeDashboardPage> {
  late MatchService _matchService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    _matchService = MatchService(authService);
    _fetchMatches();
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getRefereeMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Arbitre'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(match['description'] ?? 'No description'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${match['date']}'),
                  Text('Adresse: ${match['address']}'),
                  Text('Statut: ${match['status']}'),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/matchDetail', arguments: {'matchId': match['id']});
              },
            ),
          );
        },
      ),
    );
  }
}