import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/authweb_service.dart';
import '../services/match_service.dart';

class AnalystDashboardPage extends StatefulWidget {
  const AnalystDashboardPage({super.key});

  @override
  State<AnalystDashboardPage> createState() => _AnalystDashboardPageState();
}

class _AnalystDashboardPageState extends State<AnalystDashboardPage>
    with SingleTickerProviderStateMixin {
  late MatchService _matchService;
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _futureMatches = [];
  List<Map<String, dynamic>> _pastMatches = [];
  final AuthWebService _authWebService = AuthWebService();

  @override
  void initState() {
    super.initState();
    _matchService = MatchService(_authWebService);
    _tabController = TabController(length: 2, vsync: this);
    _fetchMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getAnalystMatches();
      final now = DateTime.now();

      final futureMatches = matches
          .where((match) =>
      DateTime.parse(match['date']).isAfter(now) ||
          DateTime.parse(match['date']).isAtSameMomentAs(now))
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

  Widget _buildMatchList(List<Map<String, dynamic>> matches) {
    return matches.isEmpty
        ? const Center(child: Text('Aucun match trouvé.'))
        : ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.sports_soccer,
                size: 40, color: Colors.green),
            title: Text(
                match['description'] ?? 'Match sans description'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatDateTime(match['date'] ?? '')),
                Text(
                    'Adresse : ${match['address'] ?? 'Non renseignée'}'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analyste'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes matchs'),
            Tab(text: 'Anciens matchs'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(_futureMatches),
          _buildMatchList(_pastMatches),
        ],
      ),
    );
  }
}
