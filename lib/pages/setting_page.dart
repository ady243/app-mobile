import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isCustomThemeEnabled = false;
  bool _useFingerprint = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Charge les paramètres enregistrés dans SharedPreferences
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCustomThemeEnabled = prefs.getBool('custom_theme') ?? false;
      _useFingerprint = prefs.getBool('use_fingerprint') ?? false;
    });
  }

  /// Sauvegarde un paramètre spécifique dans SharedPreferences
  void _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF01BF6B), // Couleur principale
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
                leading: const Icon(Icons.phone),
                title: const Text('Numéro de téléphone'),
                onPressed: (context) {
                  // Action à définir
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.email),
                title: const Text('Adresse e-mail'),
                onPressed: (context) {
                  // Action à définir
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

  /// Affiche un dialogue pour sélectionner une langue
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
