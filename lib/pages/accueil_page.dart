import 'package:flutter/material.dart';
import '../components/MatchCard.dart';
import '../services/MatchService.dart';


class AccueilPage extends StatefulWidget {
  const AccueilPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil',
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
          return MatchCard(
            description: match['description'],
            matchDate: match['match_date'],
            matchTime: match['match_time'],
            address: match['address'],
            numberOfPlayers: match['number_of_players'],
          );
        },
      ),
    );
  }
}