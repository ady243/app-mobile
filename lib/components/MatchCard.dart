import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart'; // Importer easy_localization

class MatchCard extends StatelessWidget {
  final String description;
  final String matchDate;
  final String matchTime;
  final String address;
  final String status;
  final int numberOfPlayers;
  final bool isJoined;
  final VoidCallback onTap;
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
    required this.onTap,
    required this.onJoin,
  }) : super(key: key);

  String getBackgroundImage() {
    switch (status) {
      case 'upcoming':
        return 'assets/images/stade.jpeg';
      case 'completed':
        return 'assets/images/stadium.jpg';
      case 'ongoing':
      default:
        return 'assets/images/terrainn.jpg';
    }
  }

  String getFormattedDate() {
    if (matchDate.isEmpty) {
      print('La date est vide');
      return tr('no_date'); // Utilisation de la traduction
    }
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(matchDate));
    } catch (e) {
      print('Format de la date invalide : $matchDate');
      return tr('invalid_date'); // Utilisation de la traduction
    }
  }

  String getFormattedTime() {
    if (matchTime.isEmpty) {
      print('L\'heure est vide');
      return tr('no_time'); // Utilisation de la traduction
    }
    try {
      final timeOnly = matchTime.split('T').last;
      final parsedTime = DateFormat("HH:mm:ss").parse(timeOnly);
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      print('Format de l\'heure invalide : $matchTime');
      return tr('invalid_time'); // Utilisation de la traduction
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = getFormattedDate();
    final formattedTime = getFormattedTime();

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(getBackgroundImage()),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  status.tr(), // Traduction du statut
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (address.isNotEmpty)
                  Text(
                    address,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                const SizedBox(height: 10),
                if (status == 'upcoming')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: onJoin,
                        child: Text(tr('join')), // Traduction du bouton
                      ),
                    ],
                  ),
                if (status == 'ongoing')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onJoin,
                        child: Text(tr('watch_live')), // Traduction du bouton
                      ),
                    ],
                  ),
                if (status == 'completed')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: onJoin,
                        child: Text(tr('view_results')), // Traduction du bouton
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
