import 'package:flutter/material.dart';
import 'package:teamup/services/auth.service.dart';

class LoginPageAnalyst extends StatefulWidget {
  const LoginPageAnalyst({super.key});

  @override
  State<LoginPageAnalyst> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageAnalyst> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeamUp - Analyst Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                '../../assets/logos/logo_green.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Connectez-vous pour gérer les matchs !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.login(_emailCtrl.text, _passCtrl.text);
                    Navigator.pushReplacementNamed(context, '/analystDashboard');
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Échec de connexion')));
                  }
                },
                child: const Text('Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}