import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text(
            'Profile',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image de profil
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://zupimages.net/up/24/23/rlrm.jpg',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "John Doe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            const Text(
              "johndoe@example.com",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Mes informations'),
            const SizedBox(height: 8),
            _buildInfoRow('Anniversaire', '01/01/1990'),
            _buildInfoRow('Location', 'Paris, France'),
            _buildInfoRow('Skill Level', 'Advanced'),
            _buildInfoRow('Favorite Sport', 'Football'),
            _buildInfoRow('Bio', 'A passionate football player who loves challenges.'),

            const SizedBox(height: 24),
            _buildSectionTitle('Player Stats'),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatTile('PAC', 90)),
                Expanded(child: _buildStatTile('SHO', 85)),
                Expanded(child: _buildStatTile('PAS', 88)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatTile('DRI', 91)),
                Expanded(child: _buildStatTile('DEF', 70)),
                Expanded(child: _buildStatTile('PHY', 82)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatTile('Matches Played', 120)),
                Expanded(child: _buildStatTile('Matches Won', 85)),
                Expanded(child: _buildStatTile('Goals Scored', 50)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStatTile('Behavior Score', 95)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserProfilePage(),
  ));
}
