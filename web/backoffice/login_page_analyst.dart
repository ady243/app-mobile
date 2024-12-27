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
        title: const Text('Analyst Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.login(_emailCtrl.text, _passCtrl.text);
                  // Si aucun problème, on navigue
                  Navigator.pushReplacementNamed(context, '/refereeDashboard', arguments: {'authService': _authService});
                } catch (e) {
                  // En cas d'échec de la connexion
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login failed')));
                }
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
