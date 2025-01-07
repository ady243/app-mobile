import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup/services/auth.service.dart';
import '../services/match_service.dart';

class AnalystDashboardPage extends StatefulWidget {
  const AnalystDashboardPage({super.key});

  @override
  State<AnalystDashboardPage> createState() => _AnalystDashboardPageState();
}

class _AnalystDashboardPageState extends State<AnalystDashboardPage> {
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
      final matches = await _matchService.getAnalystMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  String formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final formattedDate = DateFormat('dd-MM-yyyy').format(date);
      final formattedTime = DateFormat('HH:mm').format(date);
      return 'Date : $formattedDate\nHeure : $formattedTime';
    } catch (e) {
      print('Erreur de formatage : $e');
      return 'Format de date invalide';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analyste'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
          ? const Center(child: Text('Aucun match trouvé.'))
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.sports_soccer, size: 40, color: Colors.green),
              title: Text(match['description'] ?? 'Match sans description'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatDateTime(match['date'] ?? '')),
                  Text('Adresse : ${match['address'] ?? 'Non renseignée'}'),
                  Text('Statut : ${match['status'] ?? 'Inconnu'}'),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/eventManagement',
                  arguments: match['id'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
