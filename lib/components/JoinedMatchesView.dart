import 'package:flutter/material.dart';
import '../components/MatchCard.dart';

class JoinedMatchesView extends StatelessWidget {
  final List<Map<String, dynamic>> matches;
  final String? userId;
  final Function(String) onJoinMatch;

  const JoinedMatchesView({
    Key? key,
    required this.matches,
    required this.userId,
    required this.onJoinMatch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          description: match['description'],
          matchDate: match['date'],
          matchTime: match['time'],
          endTime: match['end_time'], // Added the required endTime argument
          address: match['address'],
          status: match['status'],
          numberOfPlayers: match['number_of_players'],
          isJoined: true,
          isOrganizer: match['organizer_id'] == userId,
          onJoin: () => onJoinMatch(match['id']),
        );
      },
    );
  }
}