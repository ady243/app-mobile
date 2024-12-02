import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatelessWidget {
  final String description;
  final String matchDate;
  final String matchTime;
  final String address;
  final String status;
  final int numberOfPlayers;
  final bool isJoined;
  final VoidCallback? onTap;
  final VoidCallback onJoin;

  const MatchCard({
    Key? key,
    required this.description,
    required this.matchDate,
    required this.matchTime,
    required this.address,
    required this.status,
    required this.numberOfPlayers,
    required this.isJoined,
    this.onTap,
    required this.onJoin,
  }) : super(key: key);

  bool _isMatchInPast() {
    try {
      final DateTime now = DateTime.now();
      final DateTime matchDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$matchDate $matchTime');
      return matchDateTime.isBefore(now);
    } catch (e) {
      print('Erreur lors de la conversion de la date et de l\'heure: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMatchInPast = _isMatchInPast();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/football.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
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
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        numberOfPlayers.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!isMatchInPast)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: isJoined ? null : onJoin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isJoined ? Colors.grey : Colors.green,
                        ),
                        child: Text(
                          isJoined ? 'Vous avez rejoint' : 'Réjoindre le match',
                          style: const TextStyle(
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
      ),
    );
  }
}