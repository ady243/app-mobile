import 'package:flutter/material.dart';
import '../components/MatchCard.dart';
import '../services/MatchService.dart';
import 'MatchDetailsPage.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final MatchService _matchService = MatchService();
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching matches: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMatchDetails(String matchId) {
    print('Navigating to match details for ID: $matchId'); // Debug statement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(matchId: matchId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accueil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];

          // Debug prints to check for null values
          print('Match Data: $match');
          String description = match['description'] ?? 'No Description';
          String matchDate = match['match_date'] ?? 'No Date';
          String matchTime = match['match_time'] ?? 'No Time';
          String address = match['address'] ?? 'No Address';
          int numberOfPlayers = match['number_of_players'] ?? 0;
          String matchId = match['match_id']?.toString() ?? '';

          return MatchCard(
            description: description,
            matchDate: matchDate,
            matchTime: matchTime,
            address: address,
            numberOfPlayers: numberOfPlayers,
            onTap: () => _navigateToMatchDetails(matchId),
          );
        },
      ),
    );
  }
}