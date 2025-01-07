import 'package:flutter/material.dart';
import 'package:teamup/components/AccueilTab.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: themeProvider.primaryColor,
          toolbarHeight: 150,
          title: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logos/grey_logo.png',
                height: 100,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Matchs Actuels'),
                Tab(text: 'Matchs Passés'),
              ],
              indicatorColor: Colors.green,
              labelColor: Color(0xFF01BF6B),
              unselectedLabelColor: Colors.green,
            ),
            const Expanded(
              child: AccueilTab(),
            ),
          ],
        ),
      ),
    );
  }
}
