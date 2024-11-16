import 'package:flutter/material.dart';
import '../services/MatchService.dart';
import 'PlayerList.dart';

class MatchInfoTab extends StatefulWidget {
  final String matchId;

  const MatchInfoTab({super.key, required this.matchId});

  @override
  _MatchInfoTabState createState() => _MatchInfoTabState();
}

class _MatchInfoTabState extends State<MatchInfoTab> {
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (matchDetails == null) {
      return const Center(child: Text('Aucun détail disponible.'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              matchDetails!['description'] ?? 'Match de foot',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Organisé par: ${matchDetails!['organizer']['username']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Date: ${matchDetails!['date']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Heure: ${matchDetails!['time']}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Adresse: ${matchDetails!['address']}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PlayerList(players: matchDetails!['players'] ?? []),
          ],
        ),
      ),
    );
  }
}