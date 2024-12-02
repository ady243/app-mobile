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
  final Set<String> _joinedMatches = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAndMatches();
  }

  void _fetchUserAndMatches() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo != null && userInfo.containsKey('id')) {
      final userId = userInfo['id'];
      _loadJoinedMatches(userId);
      _fetchMatches();
    }
  }

  void _loadJoinedMatches(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final joinedMatches = prefs.getStringList('joinedMatches_$userId') ?? [];
    setState(() {
      _joinedMatches.addAll(joinedMatches);
    });
  }

  void _saveJoinedMatches(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('joinedMatches_$userId', _joinedMatches.toList());
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToMatchDetails(String matchId) {
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

      await _matchService.joinMatch(matchId, playerId);
      setState(() {
        _joinedMatches.add(matchId);
      });
      _saveJoinedMatches(playerId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez rejoint le match !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la tentative de rejoindre le match.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          title: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Image.asset(
                'assets/logos/grey_logo.png',
                height: 100,
                width: 100,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF01BF6B),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
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
            onTap: _joinedMatches.contains(matchId)
                ? () => _navigateToMatchDetails(matchId)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/image_empty.png',
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun match disponible pour le moment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Revenez plus tard ou créez un nouveau match !',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}