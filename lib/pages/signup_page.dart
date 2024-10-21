import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../components/ToastComponent.dart';
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
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final location = _locationController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ToastComponent.showToast(context, "Les mots de passe ne correspondent pas", ToastificationType.error);
      return;
    }

    if (!_isEmailValid(email)) {
      ToastComponent.showToast(context, "Adresse email non valide", ToastificationType.error);
      return;
    }

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ToastComponent.showToast(context, "Veuillez remplir tous les champs", ToastificationType.error);
      return;
    }

    if (location.isEmpty) {
      ToastComponent.showToast(context, "Veuillez renseigner votre adresse", ToastificationType.error);
      return;
    }

    try {
      await _authService.register(username, email, password);
      ToastComponent.showToast(context, "Inscription réussie", ToastificationType.success);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ToastComponent.showToast(context, "Erreur lors de l'inscription : ${e.toString()}", ToastificationType.error);
    }
  }

  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
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
              _buildLoginOption(), // Add this line
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
        _buildTextField(_locationController, "Adresse", Icons.home),
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
        fillColor: Color(0xFF01BF6B).withOpacity(0.1),
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
        backgroundColor: const Color(0xFF01BF6B),
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
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: const Text(
            "Se connecter",
            style: TextStyle(color: Color(0xFF01BF6B)),
          ),
        ),
      ],
    );
  }

}