import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/user_profile.dart';
import '../services/MatchService.dart';

class MatchInfoTab extends StatefulWidget {
  final String matchId;

  const MatchInfoTab({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchInfoTabState createState() => _MatchInfoTabState();
}

class _MatchInfoTabState extends State<MatchInfoTab> {
  late Future<Map<String, dynamic>> _matchDetails;
  late Future<List<Map<String, dynamic>>> _matchPlayers;

  @override
  void initState() {
    super.initState();
    _matchDetails = MatchService().getMatchDetails(widget.matchId);
    _matchPlayers = MatchService().getMatchPlayers(widget.matchId);
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  String _formatTime(String time) {
    final DateTime parsedTime = DateTime.parse(time);
    return DateFormat('HH:mm').format(parsedTime);
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePages(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _matchDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Aucune donnée disponible'));
        } else {
          final matchDetails = snapshot.data!;
          final description = matchDetails['description'] ?? 'No Description';
          final address = matchDetails['address'] ?? 'No Address';
          final matchDate = matchDetails['date'] ?? 'No Date';
          final matchTime = matchDetails['time'] ?? 'No Time';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, color: Colors.blue),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text('Titre: $description')),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text('Adresse: $address')),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.green),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text('Date: ${_formatDate(matchDate)}')),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.orange),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text('Heure: ${_formatTime(matchTime)}')),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _matchPlayers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Pas encore de participants dans ce match.');
                    } else {
                      final participants = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: participants.map<Widget>((participant) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(participant['username'] ?? 'Unknown'),
                            onTap: () => _navigateToUserProfile(participant['id']),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}