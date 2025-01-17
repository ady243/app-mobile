import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/authweb_service.dart';
import '../services/match_service.dart';
import '../widgets/sidebar.dart';

class AnalystDashboardPage extends StatefulWidget {
  const AnalystDashboardPage({Key? key}) : super(key: key);

  @override
  State<AnalystDashboardPage> createState() => _AnalystDashboardPageState();
}

class _AnalystDashboardPageState extends State<AnalystDashboardPage> {
  late MatchService _matchService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _futureMatches = [];
  List<Map<String, dynamic>> _pastMatches = [];
  String _currentView = "Matchs à venir";
  final AuthWebService _authWebService = AuthWebService();

  @override
  void initState() {
    super.initState();
    _matchService = MatchService(_authWebService);
    _fetchMatches();
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getAnalystMatches();
      final now = DateTime.now();

      final futureMatches = matches
          .where((match) => DateTime.parse(match['date']).isAfter(now))
          .toList();

      final pastMatches = matches
          .where((match) => DateTime.parse(match['date']).isBefore(now))
          .toList();

      futureMatches.sort((a, b) =>
          DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      pastMatches.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

      setState(() {
        _futureMatches = futureMatches;
        _pastMatches = pastMatches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await _authWebService.logout();
    Navigator.pushReplacementNamed(context, '/loginAnalyst');
  }

  void _changeView(String view) {
    setState(() {
      _currentView = view;
    });
  }

  String formatDateTime(String date, String time) {
    try {
      final datePart = date.split('T')[0];
      final timePart = time.split('T')[1];

      final dateTime = DateTime.parse('$datePart $timePart');

      final formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      final formattedTime = DateFormat('HH:mm').format(dateTime);

      return '$formattedDate • $formattedTime';
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  String encodeToUtf8(String input) {
    try {
      final bytes = latin1.encode(input);
      return utf8.decode(bytes);
    } catch (e) {
      return 'Adresse invalide';
    }
  }

  Widget _buildMatchTable(List<Map<String, dynamic>> matches) {
    return matches.isEmpty
        ? const Center(child: Text('Aucun match trouvé.'))
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Adresse')),
          DataColumn(label: Text('Actions')),
        ],
        rows: matches.map((match) {
          return DataRow(
            cells: [
              DataCell(Text(match['description'] ?? 'N/A')),
              DataCell(Text(formatDateTime(match['date'] ?? '', match['time'] ?? ''))),
              DataCell(Text(encodeToUtf8(match['address'] ?? 'Non renseignée'))),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    final matchId = match['id'];
                    Navigator.pushNamed(
                        context, '/eventManagement/$matchId');
                  },
                  child: const Text('Détails'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onLogout: _logout,
            onNavigateDashboard: () {},
            extraItems: [
              ListTile(
                leading: const Icon(Icons.sports_soccer, color: Colors.white),
                title: const Text(
                  'Matchs à venir',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _changeView('Matchs à venir'),
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text(
                  'Anciens matchs',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => _changeView('Anciens matchs'),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                  ),
                  child: Text(
                    _currentView,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _currentView == "Matchs à venir"
                        ? _buildMatchTable(_futureMatches)
                        : _buildMatchTable(_pastMatches),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
