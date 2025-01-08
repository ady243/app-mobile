import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/theme_provider.dart';
import '../services/auth.service.dart';
import 'package:provider/provider.dart';

class Number {
  final int value;
  final int max;
  final int min;

  Number(this.value, this.max, this.min);

  static Number fromValue(int value) {
    return Number(value.clamp(0, 99), 99, 0);
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _username;
  String? _email;
  String? _bio;
  String? _location;
  String? _favoriteSport;
  late Number _matches_played = Number(0, 99, 0);
  late Number _matchWon = Number(0, 99, 0);
  late Number _goals_scored = Number(0, 99, 0);
  late Number _behavior_score = Number(0, 99, 0);
  late Number _pac = Number(0, 99, 0);
  late Number? _sho = Number(0, 99, 0);
  late Number? _pas = Number(0, 99, 0);
  late Number? _dri = Number(0, 99, 0);
  late Number? _def = Number(0, 99, 0);
  late Number? _phy = Number(0, 99, 0);

  final TextEditingController _shoController = TextEditingController();
  final TextEditingController _pasController = TextEditingController();
  final TextEditingController _driController = TextEditingController();
  final TextEditingController _defController = TextEditingController();
  final TextEditingController _phyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    setState(() {
      _username = userInfo?['username'];
      _email = userInfo?['email'];
      _bio = userInfo?['bio'];
      _location = userInfo?['location'];
      _favoriteSport = userInfo?['favorite_sport'];

      _matches_played = Number(userInfo?['matches_played'], 99, 0);
      _matchWon = Number(userInfo?['matches_won'], 99, 0);
      _goals_scored = Number(userInfo?['goals_scored'], 99, 0);
      _behavior_score = Number(userInfo?['behavior_score'], 99, 0);
      _pac = Number(userInfo?['pac'], 99, 0);
      _sho = Number(userInfo?['sho'], 99, 0);
      _pas = Number(userInfo?['pas'], 99, 0);
      _dri = Number(userInfo?['dri'], 99, 0);
      _def = Number(userInfo?['def'], 99, 0);
      _phy = Number(userInfo?['phy'], 99, 0);
      _pac = Number(userInfo?['pac'], 99, 0);
    });
  }

  Future<void> _updateUserStats() async {
    final data = {
      'matches_played': _matches_played.value,
      'matches_won': _matchWon.value,
      'goals_scored': _goals_scored.value,
      'behavior_score': _behavior_score.value,
      'pac': _pac.value,
      'sho': _sho?.value ?? 0,
      'pas': _pas?.value ?? 0,
      'dri': _dri?.value ?? 0,
      'def': _def?.value ?? 0,
      'phy': _phy?.value ?? 0,
    };

    try {
      final updatedStats = await AuthService().updateUser(data);
      if (updatedStats != null) {
        setState(() {
          _matches_played = Number(updatedStats['matches_played'], 99, 0);
          _matchWon = Number(updatedStats['matches_won'], 99, 0);
          _goals_scored = Number(updatedStats['goals_scored'], 99, 0);
          _behavior_score = Number(updatedStats['behavior_score'], 99, 0);
          _pac = Number(updatedStats['pac'], 99, 0);
          _sho = Number(updatedStats['sho'], 99, 0);
          _pas = Number(updatedStats['pas'], 99, 0);
          _dri = Number(updatedStats['dri'], 99, 0);
          _def = Number(updatedStats['def'], 99, 0);
          _phy = Number(updatedStats['phy'], 99, 0);
        });
      }
    } catch (e) {
      // Gérez les erreurs ici
    }
  }

  void _openEditDialog(
      String title, TextEditingController controller, Function onSave) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier $title'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Entrez une nouvelle valeur pour $title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                onSave();
                _updateUserStats();
                Navigator.of(context).pop();
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/football.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
                  top: 50,
                  left: 16,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _email ?? 'chargement ...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildInfoTile(FontAwesomeIcons.user, 'Bio',
                      _bio ?? 'Non spécifié', Colors.purple),
                  _buildInfoTile(FontAwesomeIcons.mapMarkerAlt, 'Localisation',
                      _location ?? 'Non spécifié', Colors.red),
                  _buildInfoTile(FontAwesomeIcons.footballBall, 'Sport préféré',
                      _favoriteSport ?? 'Non spécifié', Colors.green),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Compétences',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildEditableStatCard(FontAwesomeIcons.bullseye, 'Tir',
                      _sho?.value ?? 0, Colors.orange, _shoController, () {
                    setState(() {
                      _sho = Number.fromValue(int.parse(_shoController.text));
                    });
                  }),
                  _buildEditableStatCard(FontAwesomeIcons.handshake, 'Passe',
                      _pas?.value ?? 0, Colors.blue, _pasController, () {
                    setState(() {
                      _pas = Number.fromValue(int.parse(_pasController.text));
                    });
                  }),
                  _buildEditableStatCard(FontAwesomeIcons.running, 'Dribble',
                      _dri?.value ?? 0, Colors.pink, _driController, () {
                    setState(() {
                      _dri = Number.fromValue(int.parse(_driController.text));
                    });
                  }),
                  _buildEditableStatCard(FontAwesomeIcons.shieldAlt, 'Défense',
                      _def?.value ?? 0, Colors.teal, _defController, () {
                    setState(() {
                      _def = Number.fromValue(int.parse(_defController.text));
                    });
                  }),
                  _buildEditableStatCard(FontAwesomeIcons.dumbbell, 'Physique',
                      _phy?.value ?? 0, Colors.brown, _phyController, () {
                    setState(() {
                      _phy = Number.fromValue(int.parse(_phyController.text));
                    });
                  }),
                  _buildEditableStatCard(FontAwesomeIcons.tachometer, 'Vitesse',
                      _pac.value, Colors.purple, _shoController, () {
                    setState(() {
                      _pac = Number.fromValue(int.parse(_shoController.text));
                    });
                  }),
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
                          'Matches Joués', _matches_played.value, Colors.blue),
                      _buildStatCard(
                          'Matches Gagnés', _matchWon.value, Colors.green),
                      _buildStatCard(
                          'Buts Marqués', _goals_scored.value, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('PAC', _pac.value, Colors.purple),
                      _buildStatCard('SHO', _sho?.value ?? 0, Colors.orange),
                      _buildStatCard('PAS', _pas?.value ?? 0, Colors.blue),
                      _buildStatCard('DRI', _dri?.value ?? 0, Colors.pink),
                      _buildStatCard('DEF', _def?.value ?? 0, Colors.teal),
                      _buildStatCard('PHY', _phy?.value ?? 0, Colors.brown),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String title, String value, Color iconColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text('$title : $value'),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildEditableStatCard(IconData icon, String title, int value,
      Color color, TextEditingController controller, Function onSave) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text('$title : $value'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            controller.text = value.toString();
            _openEditDialog(title, controller, () {
              onSave();
              _updateUserStats();
            });
          },
        ),
      ),
    );
  }
}
