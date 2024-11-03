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

            if (index >= playerPositions.length) return Container();

            final dx = playerPositions[index].dx * MediaQuery.of(context).size.width;
            final dy = playerPositions[index].dy * MediaQuery.of(context).size.height;
            print('Position du joueur ${player['username']}: ($dx, $dy)'); // Debugging

            return Positioned(
              left: dx,
              top: dy,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.blue,
                    child: Text(
                      player['username'] != null ? player['username'][0].toUpperCase() : '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player['position'] != null ? player['position'] : '',
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
    final positions = <Offset>[];
    final formationLines = formationData.split('\n');
    print('Formation reçue : $formationLines');

    for (var line in formationLines) {
      if (line.contains('Gardien')) {
        positions.add(Offset(0.5, 0.9));
      } else if (line.contains('Défenseurs')) {
        positions.add(Offset(0.15, 0.7));
        positions.add(Offset(0.35, 0.7));
        positions.add(Offset(0.65, 0.7));
        positions.add(Offset(0.85, 0.7));
      } else if (line.contains('Milieux de terrain')) {
        positions.add(Offset(0.2, 0.5));
        positions.add(Offset(0.5, 0.5));
        positions.add(Offset(0.8, 0.5));
      } else if (line.contains('Attaquants')) {
        positions.add(Offset(0.2, 0.3));
        positions.add(Offset(0.5, 0.2));
        positions.add(Offset(0.8, 0.3));
      }
    }

    print('Positions générées : $positions');
    return positions;
  }

}