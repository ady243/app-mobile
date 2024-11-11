import 'package:flutter/material.dart';
import '../services/match.service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late Future<List<Match>> futureMatches;

  @override
  void initState() {
    super.initState();
    final matchService = MatchService();
    futureMatches = matchService.fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Match>>(
        future: futureMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors de la récupération des matchs.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun match trouvé.'));
          }

          final matches = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: matches.map((match) => _buildInfoCard(match)).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Match match) {
    // Sélectionne l'image d'arrière-plan en fonction du statut du match
    String getBackgroundImage() {
      switch (match.status) {
        case 'upcoming':
          return '../lib/assets/images/stade.jpeg';
        case 'completed':
          return '../lib/assets/images/stadium.jpg';
        case 'ongoing':
        default:
          return '../lib/assets/images/terrainn.jpg';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0, // Retire l'ombre
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(getBackgroundImage()), // Image en fonction du statut
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Assombrir l'image
              BlendMode.darken, // Mode de mélange pour assombrir
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
                    match.organizer,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Couleur du texte sur l'image
                    ),
                  ),
                  Text(
                    "${match.matchDate.toLocal()}".split(' ')[0], // Date formatting
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                match.status,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              if (match.address.isNotEmpty)
                Text(
                  match.address,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              const SizedBox(height: 10),
              if (match.status == 'upcoming')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Action to join the match
                      },
                      child: const Text('Rejoindre'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
