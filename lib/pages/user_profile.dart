import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import '../services/auth.service.dart';

class UserProfilePages extends StatelessWidget {
  final String userId;

  const UserProfilePages({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        backgroundColor: themeProvider.primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getUserInfoById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Aucune donnée disponible'));
          } else {
            final userDetails = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userDetails['profile_photo'] != null
                          ? NetworkImage(userDetails['profile_photo'])
                          : AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: Text(
                      userDetails['username'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 16.0),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(userDetails['location'] ?? 'Non spécifié'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: Text(
                        'Niveau de compétence: ${userDetails['skill_level'] ?? 'Non spécifié'}'),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.sports_soccer, color: Colors.green),
                    title: Text(
                        'Sport préféré: ${userDetails['favorite_sport'] ?? 'Non spécifié'}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: Text('Bio: ${userDetails['bio'] ?? 'Non spécifié'}'),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Statistiques',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                          'Matches Joués', userDetails['matches_played'] ?? 0),
                      _buildStatCard(
                          'Matches Gagnés', userDetails['matches_won'] ?? 0),
                      _buildStatCard(
                          'Buts Marqués', userDetails['goals_scored'] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('PAC', userDetails['pac'] ?? 0),
                      _buildStatCard('SHO', userDetails['sho'] ?? 0),
                      _buildStatCard('PAS', userDetails['pas'] ?? 0),
                      _buildStatCard('DRI', userDetails['dri'] ?? 0),
                      _buildStatCard('DEF', userDetails['def'] ?? 0),
                      _buildStatCard('PHY', userDetails['phy'] ?? 0),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
