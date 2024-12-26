import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teamup/pages/signup_page.dart';
import 'package:toastification/toastification.dart';
import '../components/ToastComponent.dart';
import '../services/auth.service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _logo(),
                const SizedBox(height: 20),
                _header(),
                const SizedBox(height: 20),
                _inputFields(context),
                const SizedBox(height: 10),
                _forgotPassword(context),
                const SizedBox(height: 10),
                _signup(context),
                const SizedBox(height: 20),
                _buildGoogleSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      'assets/logos/logo_green.png',
      height: 100,
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "Ha vous revoilà!",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text("Connectez-vous pour continuer"),
      ],
    );
  }

  Widget _inputFields(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
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
            hintText: "Mot de passe",
            border: OutlineInputBorder(
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
                ToastComponent.showToast(
                    context, "Connexion réussie", ToastificationType.success);
              } catch (e) {
                ToastComponent.showToast(context, "Erreur lors de la connexion",
                    ToastificationType.error);
              }
            } else {
              ToastComponent.showToast(context,
                  "Veuillez remplir tous les champs", ToastificationType.error);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color(0xFF01BF6B),
          ),
          child: const Text(
            "Se connecter",
            style: TextStyle(
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
        ToastComponent.showToast(
            context,
            "Contactez l'administrateur pour réinitialiser votre mot de passe.",
            ToastificationType.info);
      },
      child: const Text(
        "Mot de passe oublié ?",
        style: TextStyle(color: Colors.green),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous n'avez pas de compte ?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: const Text(
            "S'inscrire",
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: () async {
        try {
          await _handleGoogleSignIn();
        } catch (e) {
          // ignore: use_build_context_synchronously
          ToastComponent.showToast(
              context,
              "Erreur lors de la connexion avec Google",
              ToastificationType.error);
        }
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: Image.asset(
          'assets/logos/google_light.png',
          height: 30,
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _authService.googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final response =
            await _authService.loginWithGoogle(googleAuth.idToken!);
        if (response) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          ToastComponent.showToast(
              context, "Connexion réussie", ToastificationType.success);
        } else {
          ToastComponent.showToast(
              context,
              "Erreur lors de la connexion avec Google",
              ToastificationType.error);
        }
      }
    } catch (e) {
      print('Erreur lors de la connexion avec Google: $e');
      ToastComponent.showToast(context,
          "Erreur lors de la connexion avec Google", ToastificationType.error);
    }
  }
}
