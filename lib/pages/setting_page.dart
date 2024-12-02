import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isCustomThemeEnabled = false;
  bool _useFingerprint = false;
  String? _username;
  String? _email;
  String? _bio;
  String? _location;
  String? _favoriteSport;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _favoriteSportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchUserInfo();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCustomThemeEnabled = prefs.getBool('custom_theme') ?? false;
      _useFingerprint = prefs.getBool('use_fingerprint') ?? false;
    });
  }

  void _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _fetchUserInfo() async {
    final userInfo = await AuthService().getUserInfo();
    setState(() {
      _username = userInfo?['username'];
      _email = userInfo?['email'];
      _bio = userInfo?['bio'];
      _location = userInfo?['location'];
      _favoriteSport = userInfo?['favorite_sport'];

      _usernameController.text = _username ?? '';
      _emailController.text = _email ?? '';
      _bioController.text = _bio ?? '';
      _locationController.text = _location ?? '';
      _favoriteSportController.text = _favoriteSport ?? '';
    });
  }

  Future<void> _updateUser() async {
    final data = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
      'favorite_sport': _favoriteSportController.text,
    };

    try {
      final updatedUser = await AuthService().updateUser(data);
      if (updatedUser != null) {
        setState(() {
          _username = updatedUser['username'];
          _email = updatedUser['email'];
          _bio = updatedUser['bio'];
          _location = updatedUser['location'];
          _favoriteSport = updatedUser['favorite_sport'];
        });
      }
    } catch (e) {
      print('Erreur lors de la mise à jour des informations utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Général'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('Langue'),
                value: const Text('Français'),
                onPressed: (context) {
                  _showLanguageDialog(context);
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    _isCustomThemeEnabled = value;
                    _saveSetting('custom_theme', value);
                  });
                },
                initialValue: _isCustomThemeEnabled,
                leading: const Icon(Icons.format_paint),
                title: const Text('Activer le thème personnalisé'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Compte'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.person),
                title: const Text('Nom d\'utilisateur'),
                value: Text(_username ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'Nom d\'utilisateur', _usernameController);
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.email),
                title: const Text('Adresse e-mail'),
                value: Text(_email ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'Adresse e-mail', _emailController);
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.info),
                title: const Text('Bio'),
                value: Text(_bio ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'Bio', _bioController);
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.location_on),
                title: const Text('Localisation'),
                value: Text(_location ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'Localisation', _locationController);
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.sports_soccer),
                title: const Text('Sport préféré'),
                value: Text(_favoriteSport ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'Sport préféré', _favoriteSportController);
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Sécurité'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    _useFingerprint = value;
                    _saveSetting('use_fingerprint', value);
                  });
                },
                initialValue: _useFingerprint,
                leading: const Icon(Icons.fingerprint),
                title: const Text('Utiliser l\'empreinte digitale'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.lock),
                title: const Text('Changer le mot de passe'),
                onPressed: (context) {
                  Navigator.pushNamed(context, '/change-password');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditDialog(BuildContext context, String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Entrez une nouvelle valeur pour $field'),
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
                _updateUser();
                Navigator.of(context).pop();
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir une langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Langue définie sur Français')),
                  );
                },
              ),
              ListTile(
                title: const Text('Anglais'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Langue définie sur Anglais')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}