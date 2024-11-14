import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/services/auth.service.dart';
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
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _nearbyMatches = [];
  final Set<String> _joinedMatches = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinedMatches();
    _fetchMatches();
  }

  void _loadJoinedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedMatches = prefs.getStringList('joinedMatches') ?? [];
    setState(() {
      _joinedMatches.addAll(joinedMatches);
    });
  }

  void _saveJoinedMatches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('joinedMatches', _joinedMatches.toList());
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

  void _showNearbyMatches() async {
    setState(() => _isLoading = true);
    try {
      final nearbyMatches = await _matchService.getNearbyMatches();
      setState(() {
        _nearbyMatches = nearbyMatches;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching nearby matches: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToMatchDetails(String matchId) {
    print('Navigating to match details for ID: $matchId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(matchId: matchId),
      ),
    );
  }

  void _joinMatch(String matchId) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null || !userInfo.containsKey('id')) {
        throw Exception('Impossible de récupérer l\'ID utilisateur');
      }
      final playerId = userInfo['id'];
      print('Données envoyées pour rejoindre le match: {match_id: $matchId, player_id: $playerId}');

      await _matchService.joinMatch(matchId, playerId);
      setState(() {
        _joinedMatches.add(matchId);
      });
      _saveJoinedMatches();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez rejoint le match !')),
      );
    } catch (e) {
      print('Error joining match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la tentative de rejoindre le match.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Team Up',
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
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showNearbyMatches,
              child: const Text('Autour de moi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: (_nearbyMatches.isNotEmpty ? _nearbyMatches : _matches).length,
              itemBuilder: (context, index) {
                final match = (_nearbyMatches.isNotEmpty ? _nearbyMatches : _matches)[index];
                print('Match Data: $match');
                String description = match['description'] ?? 'No Description';
                String matchDate = match['match_date'] ?? 'No Date';
                String matchTime = match['match_time'] ?? 'No Time';
                String status = match['status'] ?? 'No Status';
                String address = match['address'] ?? 'No Address';
                int numberOfPlayers = match['number_of_players'] ?? 0;
                String matchId = match['id']?.toString() ?? '';

                return MatchCard(
                  description: description,
                  matchDate: matchDate,
                  matchTime: matchTime,
                  status: status,
                  address: address,
                  numberOfPlayers: numberOfPlayers,
                  isJoined: _joinedMatches.contains(matchId),
                  onJoin: () => _joinMatch(matchId),
                  onTap: () => _navigateToMatchDetails(matchId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
