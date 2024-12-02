import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      await _matchService.deleteMatch(matchId);
      setState(() {
        _matches.removeWhere((match) => match['id'] == matchId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match supprimé avec succès')),
      );
    } catch (e) {
      print('Erreur lors de la suppression du match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du match')),
      );
    }
  }

  void _showDeleteDialog(String matchId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.red),
              SizedBox(width: 10),
              Text('Supprimer le match'),
            ],
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce match ? Cette action est irréversible.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
          : Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Glissez vers la gauche pour supprimer un match',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                    child: const FaIcon(FontAwesomeIcons.trash, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: const FaIcon(FontAwesomeIcons.futbol, color: Color(0xFF01BF6B)),
                      title: Text(match['description'] ?? 'No Description'),
                      subtitle: Text(match['match_date'] ?? 'No Date'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}