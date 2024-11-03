import 'package:flutter/material.dart';
import '../components/FormationField.dart';
import '../services/MatchService.dart';
import 'ChatPage.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  const MatchDetailsPage({super.key, required this.matchId});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final MatchService _matchService = MatchService();
  Map<String, dynamic>? matchDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  void _fetchMatchDetails() async {
    try {
      final details = await _matchService.getMatchWithPlayers(widget.matchId);
      setState(() {
        matchDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching match details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(matchId: widget.matchId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du Match',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchDetails == null
          ? const Center(child: Text('Aucun détail disponible'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formation',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              FormationField(
                formationData: matchDetails!['formations'][0] ?? '',
                players: matchDetails!['players'] ?? [],
              ),
              const SizedBox(height: 16),
              Text(
                'Participants',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...matchDetails!['players'].map<Widget>((player) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      player['username'] != null ? player['username'][0].toUpperCase() : '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(player['username'] ?? ''),
                  subtitle: Text('Position: ${player['position'] ?? ''}'),
                );
              }).toList(),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _navigateToChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}