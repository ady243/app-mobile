import 'package:flutter/material.dart';

class PlayerList extends StatelessWidget {
  final List players;

  const PlayerList({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Text('Aucun joueur inscrit pour le moment.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: players.map<Widget>((player) {
        return Row(
          children: [
            const Icon(Icons.account_circle, color: Colors.grey),
            const SizedBox(width: 8),
            Text(player['username']),
          ],
        );
      }).toList(),
    );
  }
}