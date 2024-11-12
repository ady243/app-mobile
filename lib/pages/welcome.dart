import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/services/auth.service.dart';
import '../components/MatchCard.dart';
import '../services/MatchService.dart';
import 'MatchDetailsPage.dart';
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _matches = [];
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
        SnackBar(content: Text(tr('join_match_success'))),
      );
    } catch (e) {
      print('Error joining match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('join_match_error'))),
      );
    }
  }

  // Fonction pour afficher un dialogue permettant à l'utilisateur de changer de langue
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('choose_language'.tr()),  // Utilisation de easy_localization pour traduire le titre
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  context.setLocale(Locale('en', 'US'));  // Changer la langue en anglais
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Français'),
                onTap: () {
                  context.setLocale(Locale('fr', 'FR'));  // Changer la langue en français
                  Navigator.pop(context);
                },
              ),
              // Ajouter d'autres langues ici si nécessaire
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          tr('team_up'),  // Utilisation de easy_localization pour traduire le titre de l'app
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: _isLoading
          ? Center(child: Text(tr('loading_matches')))  // Utilisation de easy_localization pour les textes
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          print('Match Data: $match');
          String description = match['description'] ?? tr('no_description');
          String matchDate = match['match_date'] ?? tr('no_date');
          String matchTime = match['match_time'] ?? tr('no_time');
          String status = match['status'] ?? tr('no_status');
          String address = match['address'] ?? tr('no_address');
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLanguageDialog(context),  // Afficher le dialogue pour changer la langue
        child: const Icon(Icons.language),
        backgroundColor: Colors.green,
        tooltip: tr('change_language'),  // Utilisation de easy_localization pour le tooltip
      ),
    );
  }
}
