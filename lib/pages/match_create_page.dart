import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le format de date

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({Key? key}) : super(key: key);

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberOfPlayersController = TextEditingController();
  final TextEditingController _scoreTeam1Controller = TextEditingController();
  final TextEditingController _scoreTeam2Controller = TextEditingController();

  // Fonction pour ouvrir le panneau modal depuis le bas
  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet au bottom sheet de s'ajuster
      builder: (BuildContext context) {
        return SingleChildScrollView( // Ajout du SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Pour que le popup s'adapte à son contenu
              children: [
                const Text(
                  'Créer un match',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _matchDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _matchDate) {
                      setState(() {
                        _matchDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Sélectionner la date',
                    ),
                    child: Text(
                      _matchDate != null ? DateFormat('yyyy-MM-dd').format(_matchDate!) : 'Date',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _matchTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null && pickedTime != _matchTime) {
                      setState(() {
                        _matchTime = pickedTime;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Sélectionner l\'heure',
                    ),
                    child: Text(
                      _matchTime != null ? _matchTime!.format(context) : 'Heure',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'Adresse'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _numberOfPlayersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Nombre de joueurs'),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Ici, tu peux ajouter la logique pour sauvegarder les données
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01BF6B),
                  ),
                  child: const Text(
                      'Créer le match',
                      style: TextStyle(
                          color: Colors.white
                      ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer un Match',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: Center(
        child: FloatingActionButton(
          onPressed: () {
            _openBottomSheet(context);
          },
          child: const Icon(Icons.add),
          backgroundColor: const Color(0xFF01BF6B),
          tooltip: 'Créer un match',
        ),
      ),
    );
  }
}
