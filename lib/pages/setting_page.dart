import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../components/theme_provider.dart';
import '../services/auth.service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? _username;
  String? _email;
  String? _bio;
  String? _location;
  String? _favoriteSport;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _favoriteSportController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
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
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('settings').tr(),
        backgroundColor: themeProvider.primaryColor,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('general').tr(),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.language),
                title: const Text('language').tr(),
                value: Text(context.locale.languageCode == 'en' ? 'English' : 'Français'),
                onPressed: (context) {
                  _showLanguageDialog(context);
                },
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  themeProvider.toggleTheme();
                },
                initialValue: themeProvider.isDarkTheme,
                leading: const Icon(Icons.format_paint),
                title: const Text('theme_change').tr(),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('account').tr(),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.person),
                title: const Text('username').tr(),
                value: Text(_username ?? ''),
                onPressed: (context) {
                  _openEditDialog(context, 'username'.tr(), _usernameController);
                },
              ),
              // Add more account settings here
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('choose_language').tr(),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français'),
                onTap: () {
                  context.setLocale(const Locale('fr', 'FR'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('language_set_fr').tr(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  context.setLocale(const Locale('en', 'US'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('language_set_en').tr(),),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditDialog(
      BuildContext context, String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('edit_field'.tr(args: [field])),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'enter_new_value'.tr(args: [field]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                _updateUser();
                Navigator.of(context).pop();
              },
              child: const Text('save').tr(),
            ),
          ],
        );
      },
    );
  }
}
