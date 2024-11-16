import 'package:flutter/material.dart';
import '../services/auth.service.dart';

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
  static String routeName = 'profile';

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _username;
  String? _email;
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
    });
  }

  Future<void> _updateUser() async {
    final data = {
      'username': _username,
      'email': _email,
      'matchesPlayed': _matches_played.value,
      'matchesWon': _matchWon.value,
      'goalsScored': _goals_scored.value,
      'behaviorScore': _behavior_score.value,
      'pac': _pac.value,
      'sho': _sho?.value,
      'pas': _pas?.value,
      'dri': _dri?.value,
      'def': _def?.value,
      'phy': _phy?.value,
    };

    try {
      final updatedUser = await AuthService().updateUser(data);
      if (updatedUser != null) {
        setState(() {
          _username = updatedUser['username'];
          _email = updatedUser['email'];
          _matches_played = Number(updatedUser['matchesPlayed'], 99, 0);
          _matchWon = Number(updatedUser['matchesWon'], 99, 0);
          _goals_scored = Number(updatedUser['goalsScored'], 99, 0);
          _behavior_score = Number(updatedUser['behaviorScore'], 99, 0);
          _pac = Number(updatedUser['pac'], 99, 0);
          _sho = Number(updatedUser['sho'], 99, 0);
          _pas = Number(updatedUser['pas'], 99, 0);
          _dri = Number(updatedUser['dri'], 99, 0);
          _def = Number(updatedUser['def'], 99, 0);
          _phy = Number(updatedUser['phy'], 99, 0);
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour des informations utilisateur: $e');
    }
  }

  void _openBottomSheet(BuildContext context, String field, TextEditingController controller, Function onSave) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Modifier $field',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Entrez une nouvelle valeur pour $field'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  onSave();
                  Navigator.of(context).pop();
                  _updateUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01BF6B),
                ),
                child: const Text('Sauvegarder',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              color: Color(0xFF01BF6B).withOpacity(0.1),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40.0,
                    color: Colors.grey,
                  ),
                ),
                title: Text(
                  _username ?? 'User',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _email ?? 'chargement ...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildStaticTile(Icons.stadium_rounded, 'Match joué', _matches_played.value),
                  _buildStaticTile(Icons.sports, 'Match gagné', _matchWon.value),
                  _buildStaticTile(Icons.sports_soccer_sharp, 'Nombre de buts', _goals_scored.value),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Text(
                      'Compétences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildEditableTile(Icons.sports_soccer, 'Tir', _sho?.value ?? 0, _shoController, () {
                    setState(() {
                      _sho = Number.fromValue(int.parse(_shoController.text));
                    });
                  }),
                  _buildEditableTile(Icons.sports_soccer, 'Passe', _pas?.value ?? 0, _pasController, () {
                    setState(() {
                      _pas = Number.fromValue(int.parse(_pasController.text));
                    });
                  }),
                  _buildEditableTile(Icons.sports_soccer, 'Dribble', _dri?.value ?? 0, _driController, () {
                    setState(() {
                      _dri = Number.fromValue(int.parse(_driController.text));
                    });
                  }),
                  _buildEditableTile(Icons.sports_soccer, 'Défense', _def?.value ?? 0, _defController, () {
                    setState(() {
                      _def = Number.fromValue(int.parse(_defController.text));
                    });
                  }),
                  _buildEditableTile(Icons.accessibility_new_sharp, 'Physique', _phy?.value ?? 0, _phyController, () {
                    setState(() {
                      _phy = Number.fromValue(int.parse(_phyController.text));
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticTile(IconData icon, String title, int value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text('$title : $value'),
      ),
    );
  }

  Widget _buildEditableTile(IconData icon, String title, int value, TextEditingController controller, Function onSave) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text('$title : $value'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            controller.text = value.toString();
            _openBottomSheet(context, title, controller, onSave);
          },
        ),
      ),
    );
  }
}