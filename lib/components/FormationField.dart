import 'package:flutter/material.dart';

import 'TerrainPainter.dart';

class FormationField extends StatelessWidget {
  final String formationData;
  final List<dynamic> players;
  final void Function(Map<String, dynamic> player)? onTap;

  const FormationField({
    super.key,
    required this.formationData,
    required this.players,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final playerPositions = _generatePlayerPositions();

    return AspectRatio(
      aspectRatio: 0.7,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: TerrainPainter(),
          ),
          ...players.asMap().entries.map((entry) {
            int index = entry.key;
            var player = entry.value;

            return Positioned(
              left: playerPositions[index].dx * MediaQuery.of(context).size.width * 0.7,
              top: playerPositions[index].dy * MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      player['username'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player['position'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Offset> _generatePlayerPositions() {
    return [
      Offset(0.5, 0.9),  // Gardien
      Offset(0.15, 0.7), // Défenseur Gauche
      Offset(0.35, 0.7), // Défenseur Central
      Offset(0.65, 0.7), // Défenseur Central
      Offset(0.85, 0.7), // Défenseur Droit
      Offset(0.2, 0.5),  // Milieu Gauche
      Offset(0.5, 0.5),  // Milieu Central
      Offset(0.8, 0.5),  // Milieu Droit
      Offset(0.2, 0.3),  // Attaquant Gauche
      Offset(0.5, 0.2),  // Attaquant Centre
      Offset(0.8, 0.3),  // Attaquant Droit
    ];
  }
}