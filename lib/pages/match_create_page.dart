import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../services/MatchService.dart';

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
  final MatchService _matchService = MatchService();

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _numberOfPlayersController.dispose();
    super.dispose();
  }

  Future<void> _createMatch() async {
    if (_matchDate == null || _matchTime == null) {
      Fluttertoast.showToast(msg: 'Veuillez sélectionner une date et une heure.');
      return;
    }

    if (_descriptionController.text.isEmpty || _addressController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Veuillez remplir tous les champs obligatoires.');
      return;
    }

    final int? numberOfPlayers = int.tryParse(_numberOfPlayersController.text);
    if (numberOfPlayers == null || numberOfPlayers <= 0) {
      Fluttertoast.showToast(msg: 'Veuillez entrer un nombre valide de joueurs.');
      return;
    }

    // Formatez l'heure correctement
    final String matchTime = _matchTime!.hour.toString().padLeft(2, '0') + ':' + _matchTime!.minute.toString().padLeft(2, '0');

    Map<String, dynamic> matchData = {
      'description': _descriptionController.text,
      'match_date': DateFormat('yyyy-MM-dd').format(_matchDate!),
      'match_time': matchTime,
      'address': _addressController.text,
      'number_of_players': numberOfPlayers,
    };

    print('Données envoyées : $matchData'); // Ajoutez ce log pour vérifier les données envoyées

    try {
      await _matchService.createMatch(matchData);
      Fluttertoast.showToast(msg: 'Match créé avec succès !');
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur lors de la création du match : $e');
    }
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

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Créer un match',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _matchDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _matchDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sélectionner la date',
                      border: OutlineInputBorder(),
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
                    if (pickedTime != null) {
                      setState(() {
                        _matchTime = pickedTime;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Sélectionner l\'heure',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _matchTime != null ? _matchTime!.format(context) : 'Heure',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _numberOfPlayersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de joueurs',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _createMatch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01BF6B),
                  ),
                  child: const Text(
                    'Créer le match',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}