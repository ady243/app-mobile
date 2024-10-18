import 'package:flutter/material.dart';
import 'dart:math';
import '../services/auth.service.dart';

class Number {
  final int value;
  final int max;
  final int min;

  Number(this.value, this.max, this.min);

  // Méthode pour créer un objet Number à partir d'une valeur existante
  static Number fromValue(int value) {
    return Number(value.clamp(0, 99), 99, 0);
  }
}

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);
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

  // Fonction pour ouvrir un panneau modal depuis le bas
  void _openBottomSheet(BuildContext context, String field, TextEditingController controller, Function onSave) {
    showModalBottomSheet(
      context: context,
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF01BF6B),
                ),
                child: const Text('Sauvegarder',style: (
                  TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),),
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
            Container(
              width: double.infinity,
              height: isTablet(context) ? 190 : 150,
              decoration: const BoxDecoration(
                color: Color(0xFF01BF6B),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      radius: isTablet(context) ? 60 : 65,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: isTablet(context) ? 60.0 : 65.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _username ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _email ?? 'chargement ...',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
                child: ListView(
                  children: [
                    _buildStaticTile(Icons.stadium_rounded, 'Match joué', _matches_played.value),
                    _buildStaticTile(Icons.sports, 'Match gagné', _matchWon.value),

                    _buildStaticTile(Icons.sports_soccer_sharp, 'Nombre de buts', _goals_scored.value),
                    Container(
                      decoration: BoxDecoration(
                        border: const Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Compétences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _buildEditableTile(Icons.sports_soccer, 'Tir', _sho?.value ?? 0, _shoController, () {
                      setState(() {
                        _sho = Number.fromValue(int.parse(_shoController.text));
                      });
                    }),
                    const Divider(),
                    _buildEditableTile(Icons.sports_soccer, 'Passe', _pas?.value ?? 0, _pasController, () {
                      setState(() {
                        _pas = Number.fromValue(int.parse(_pasController.text));
                      });
                    }),
                    const Divider(),
                    _buildEditableTile(Icons.sports_soccer, 'Dribble', _dri?.value ?? 0, _driController, () {
                      setState(() {
                        _dri = Number.fromValue(int.parse(_driController.text));
                      });
                    }),
                    const Divider(),
                    _buildEditableTile(Icons.sports_soccer, 'Défense', _def?.value ?? 0, _defController, () {
                      setState(() {
                        _def = Number.fromValue(int.parse(_defController.text));
                      });
                    }),
                    const Divider(),
                    _buildEditableTile(Icons.accessibility_new_sharp, 'Physique', _phy?.value ?? 0, _phyController, () {
                      setState(() {
                        _phy = Number.fromValue(int.parse(_phyController.text));
                      });
                    }),
                    const Divider(),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticTile(IconData icon, String title, int value) {
    return ListTile(
      leading: Icon(icon),
      title: Text('$title : $value'),
    );
  }

  Widget _buildEditableTile(IconData icon, String title, int value, TextEditingController controller, Function onSave) {
    return ListTile(
      leading: Icon(icon),
      title: Text('$title : $value'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          controller.text = value.toString();
          _openBottomSheet(context, title, controller, onSave);
        },
      ),
    );
  }

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    return diagonal > 1100.0;
  }
}
