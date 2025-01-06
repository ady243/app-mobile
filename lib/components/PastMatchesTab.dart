import 'package:flutter/material.dart';
import 'package:teamup/components/MatchCard.dart';

class PastMatchesTab extends StatelessWidget {
  final List<Map<String, dynamic>> pastMatches;
  final String userId;

  const PastMatchesTab({
    super.key,
    required this.pastMatches,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return pastMatches.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/image_empty.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Aucun match passé',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vous n\'avez rejoint aucun match passé.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: pastMatches.length,
            itemBuilder: (context, index) {
              final match = pastMatches[index];
              return MatchCard(
                description: _truncateText(match['description'] ?? '', 24),
                matchDate: match['date'] ?? '',
                matchTime: match['time'] ?? '',
                endTime: match['end_time'] ?? '',
                address: _truncateText(match['address'] ?? '', 24),
                status: match['status'] ?? '',
                numberOfPlayers: match['number_of_players'] ?? 0,
                isOrganizer: match['organizer_id'] == userId,
                joinedMatches: {match['id']},
                matchId: match['id'].toString(),
                userId: userId,
                showJoinLeaveButtons: false,
              );
            },
          );
  }

  String _truncateText(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }
}
