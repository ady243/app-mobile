import 'package:flutter/material.dart';
import '../services/auth.service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showSnackBar("Les mots de passe ne correspondent pas");
      return;
    }

    if (!_isEmailValid(email)) {
      _showSnackBar("Adresse email non valide");
      return;
    }

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs");
      return;
    }

    try {
      await _authService.register(username, email, password);
      _showSnackBar("Inscription réussie");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      _showSnackBar("Erreur lors de l'inscription : ${e.toString()}");
    }
  }

  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildInputFields(),
              _buildRegisterButton(),
              const Center(child: Text("Ou")),
              _buildLoginOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 60.0),
        const Text(
          "Créer un compte",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          "Inscrivez-vous pour accéder à l'application",
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField(_usernameController, "Nom d'utilisateur", Icons.person),
        const SizedBox(height: 20),
        _buildTextField(_emailController, "Email", Icons.email),
        const SizedBox(height: 20),
        _buildTextField(_passwordController, "Mot de passe", Icons.lock, isPassword: true),
        const SizedBox(height: 20),
        _buildTextField(_confirmPasswordController, "Confirmer votre mot de passe ", Icons.lock, isPassword: true),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.green.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.green[900],
      ),
      child: const Text(
        "S'inscrire",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous avez déjà un compte ?"),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: Text(
            "Se connecter",
            style: TextStyle(color: Colors.green[900]),
          ),
        ),
      ],
    );
  }
}
