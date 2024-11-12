import 'package:flutter/material.dart';
import 'package:teamup/pages/signup_page.dart';
import 'package:toastification/toastification.dart';
import '../components/ToastComponent.dart';
import '../services/auth.service.dart';
import 'home_page.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(),
            _inputFields(context),
            _forgotPassword(context),
            _signup(context),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLanguageDialog(context),
        child: Icon(Icons.language),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text(
          "welcome_back".tr(),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("login_instructions".tr()),
      ],
    );
  }

  Widget _inputFields(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final AuthService _authService = AuthService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "email".tr(),
            border:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color(0xFF01BF6B).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "password".tr(),
            border:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color(0xFF01BF6B).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (_emailController.text.isNotEmpty &&
                _passwordController.text.isNotEmpty) {
              try {
                await _authService.login(
                    _emailController.text, _passwordController.text);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                ToastComponent.showToast(context, "login_success".tr(), ToastificationType.success);
              } catch (e) {
                ToastComponent.showToast(context, "login_error".tr(), ToastificationType.error);
              }
            } else {
              ToastComponent.showToast(context, "fill_fields".tr(), ToastificationType.error);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF01BF6B),
          ),
          child: Text(
            "login_button".tr(),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        ToastComponent.showToast(context, "reset_password_info".tr(), ToastificationType.info);
      },
      child: Text(
        "forgot_password".tr(),
        style: const TextStyle(color: Colors.green),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("no_account".tr()),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: Text(
            "sign_up".tr(),
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      child: Center(
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          child: Image.asset(
              'assets/logos/google_light.png', height: 30),
        ),
      ),
    );
  }

  // Fonction pour afficher un dialogue permettant à l'utilisateur de changer de langue
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('choose_language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('English'),
                onTap: () {
                  context.setLocale(Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Français'),
                onTap: () {
                  context.setLocale(Locale('fr', 'FR'));
                  Navigator.pop(context);
                },
              ),
              // Ajouter d'autres langues ici si nécessaire
            ],
          ),
        );
      },
    );
  }
}
