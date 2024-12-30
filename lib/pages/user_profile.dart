import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/utils/baseUrl.dart';
import '../services/friend.service.dart';

class UserProfilePages extends StatefulWidget {
  final String userId;

  const UserProfilePages({super.key, required this.userId});

  @override
  _UserProfilePagesState createState() => _UserProfilePagesState();
}

class _UserProfilePagesState extends State<UserProfilePages> {
  bool isFriend = false;
  bool requestSent = false;
  final FriendService _friendService = FriendService();

  @override
  void initState() {
    super.initState();
    _checkFriendStatus();
  }

  void _checkFriendStatus() async {
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        isFriend = friends.any((friend) => friend['id'] == widget.userId);
      });
      if (!isFriend) {
        final requests = await _friendService.getFriendRequests();
        setState(() {
          requestSent =
              requests.any((request) => request['id'] == widget.userId);
        });
      }
    } catch (e) {
      print('Failed to check friend status: $e');
    }
  }

  void _sendFriendRequest() async {
    try {
      await _friendService.sendFriendRequest(widget.userId);
      setState(() {
        requestSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Demande d\'ami envoyée avec succès',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Failed to send friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de l\'envoi de la demande d\'ami',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        backgroundColor: themeProvider.primaryColor,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AuthService().getUserInfoById(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Aucune donnée disponible'));
          } else {
            final userDetails = snapshot.data!;
            final profilePhoto = userDetails['profile_photo'];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profilePhoto != null && profilePhoto.isNotEmpty
                              ? NetworkImage(profilePhoto)
                              : null,
                      child: profilePhoto == null || profilePhoto.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
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
                  Center(
                    child: ElevatedButton.icon(
                      onPressed:
                          isFriend || requestSent ? null : _sendFriendRequest,
                      icon: Icon(isFriend ? Icons.check : Icons.person_add),
                      label: Text(isFriend
                          ? 'Déjà amis'
                          : requestSent
                              ? 'Demande envoyée'
                              : 'Demander en ami'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
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
                    style: TextStyle(
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
