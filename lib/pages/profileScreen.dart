import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                  'https://zupimages.net/up/24/23/rlrm.jpg'),
            ),
            const SizedBox(height: 20),
            // Nom
            const Text(
              "Pseudo",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "ADY",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Informations personnelles",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    "Date de naissance: 01/01/1990",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Divider(thickness: 2, color: Colors.blueGrey),

                  SizedBox(height: 10),
                  Text(
                    "Téléphone: +33 6 15 34 56 78",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Divider(thickness: 2, color: Colors.blueGrey),

                  SizedBox(height: 5),
                  Text(
                    "Email: masivi@masivi.com", style: TextStyle(
                    fontSize: 15,
                  ),
                  ),

                  Divider(thickness: 2, color: Colors.blueGrey),

                  Text(
                    "Adresse: 153 Rue Exemple, 75000 Paris",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Divider(thickness: 2, color: Colors.blueGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
