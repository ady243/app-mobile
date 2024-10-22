import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  final String description;
  final String matchDate;
  final String matchTime;
  final String address;
  final int numberOfPlayers;

  const MatchCard({
    Key? key,
    required String? description,
    required String? matchDate,
    required String? matchTime,
    required String? address,
    required this.numberOfPlayers,
  })  : description = description ?? '',
        matchDate = matchDate ?? '',
        matchTime = matchTime ?? '',
        address = address ?? '',
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Opacity(
              opacity: 0.9, // Reduced opacity for better clarity
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/football.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Semi-transparent overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.black.withOpacity(0.3), // Reduced overlay opacity
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      matchDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      matchTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Nombre des joueurs: $numberOfPlayers',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your join match logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Réjoindre le match',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}