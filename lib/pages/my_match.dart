import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../services/MatchService.dart';

class MyCreatedMatchesPage extends StatefulWidget {
  final Future<void> Function(String) onDeleteMatch;

  const MyCreatedMatchesPage({super.key, required this.onDeleteMatch});

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
      final matches = await _matchService.getMatchesByOrganizer();
      setState(() {
        _matches = matches;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors du chargement des matchs',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Date invalide';
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
          title: const Row(
            children: [
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
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.onDeleteMatch(matchId);
                _fetchMatches();
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
                          child: const FaIcon(FontAwesomeIcons.trash,
                              color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: const FaIcon(FontAwesomeIcons.futbol,
                                color: Color(0xFF01BF6B)),
                            title:
                                Text(match['description'] ?? 'No Description'),
                            subtitle: Text(
                                _formatDate(match['match_date'] ?? 'No Date')),
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
