import 'package:flutter/material.dart';
import '../services/MatchService.dart';

class MyCreatedMatchesPage extends StatefulWidget {
  const MyCreatedMatchesPage({super.key});

  @override
  _MyCreatedMatchesPageState createState() => _MyCreatedMatchesPageState();
}

class _MyCreatedMatchesPageState extends State<MyCreatedMatchesPage> {
  final MatchService _matchService = MatchService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    try {
      print('Tentative de récupération des matchs créés par l\'organisateur...');
      final matches = await _matchService.getMatchesByOrganizer();
      print('Matchs récupérés: $matches');
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des matchs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      print('Tentative de suppression du match avec ID: $matchId');
      await _matchService.deleteMatch(matchId);
      print('Match supprimé avec succès');
      setState(() {
        _matches.removeWhere((match) => match['id'] == matchId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match supprimé avec succès')),
      );
    } catch (e) {
      print('Erreur lors de la suppression du match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du match')),
      );
    }
  }

  void _showDeleteDialog(String matchId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le match'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce match ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Supprimer'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMatch(matchId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          return Dismissible(
            key: Key(match['id']),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              _showDeleteDialog(match['id']);
              return false;
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(match['description'] ?? 'No Description'),
              subtitle: Text(match['match_date'] ?? 'No Date'),
            ),
          );
        },
      ),
    );
  }
}