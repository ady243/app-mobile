import 'package:flutter/material.dart';
import 'dart:math';
import '../services/auth.service.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({Key? key}) : super(key: key);
  static String routeName = 'profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
        actions: [
          InkWell(
            onTap: () {
              // Envoi d'un rapport à la direction de l'école, en cas de modification du profil
            },
            child: Container(
              padding: const EdgeInsets.only(right: 16.0),
              child: const Row(
                children: [
                  SizedBox(width: 8.0),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: isTablet(context) ? 190 : 150,
              decoration: const BoxDecoration(
                color: Color(0xFF01BF6B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: isTablet(context) ? 60 : 65,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: isTablet(context) ? 60.0 : 65.0, // Provide a valid double value
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Aisha Mirza',
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Class X-II A | Roll no: 12',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    return diagonal > 1100.0;
  }
}