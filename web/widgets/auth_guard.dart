import 'package:flutter/material.dart';
import '../services/authweb_service.dart';

class AuthGuard extends StatelessWidget {
  final WidgetBuilder builder;

  const AuthGuard({Key? key, required this.builder}) : super(key: key);

  Future<bool> _checkIfLoggedIn() async {
    final authWebService = AuthWebService();
    return await authWebService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return builder(context);
        } else {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/loginAnalyst');
          });
          return const Scaffold(
            body: Center(child: Text('Redirection vers la page de connexion...')),
          );
        }
      },
    );
  }
}
