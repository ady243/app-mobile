import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/MatchService.dart';
import 'my_match.dart';

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
  final String _googleApiKey = 'AIzaSyAdNnq6m3qBSXKlKK5gbQJMdbd22OWeHCg';

  String _addressQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
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

    final String matchTime = _matchTime!.hour.toString().padLeft(2, '0') + ':' + _matchTime!.minute.toString().padLeft(2, '0');

    Map<String, dynamic> matchData = {
      'description': _descriptionController.text,
      'match_date': DateFormat('yyyy-MM-dd').format(_matchDate!),
      'match_time': matchTime,
      'address': _addressController.text,
      'number_of_players': numberOfPlayers,
    };

    print('Données envoyées : $matchData');

    try {
      await _matchService.createMatch(matchData);
      Fluttertoast.showToast(msg: 'Match créé avec succès !');
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur lors de la création du match : $e');
    }
  }

  Future<void> _autoCompleteAddress(String query) async {
    if (query.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&components=country:fr';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'].isNotEmpty) {
          final String suggestion = data['predictions'][0]['description'];
          setState(() {
            _addressController.value = TextEditingValue(
              text: suggestion,
              selection: TextSelection.fromPosition(
                TextPosition(offset: query.length),
              ),
            );
          });
        }
      }
    } catch (error) {
      print('Erreur lors de la récupération des suggestions : $error');
    }
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
                  onChanged: (query) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(seconds: 6), () {
                      _autoCompleteAddress(query);
                    });
                  },
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Mes Matchs',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Mes matches créés'),
                Tab(text: 'Créer un match'),
              ],
              indicatorColor: Colors.green,
              labelColor: const Color(0xFF01BF6B),
              unselectedLabelColor: const Color(0xFF01BF6B),
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF01BF6B),
      ),
        body: TabBarView(
          children: [
            const MyCreatedMatchesPage(),
            CreateMatchPageContent(
              descriptionController: _descriptionController,
              matchDate: _matchDate,
              matchTime: _matchTime,
              addressController: _addressController,
              numberOfPlayersController: _numberOfPlayersController,
              createMatch: _createMatch,
              openBottomSheet: _openBottomSheet,
            ),
          ],
        ),
      ),
    );
  }
}

class CreateMatchPageContent extends StatelessWidget {
  final TextEditingController descriptionController;
  final DateTime? matchDate;
  final TimeOfDay? matchTime;
  final TextEditingController addressController;
  final TextEditingController numberOfPlayersController;
  final Future<void> Function() createMatch;
  final void Function(BuildContext) openBottomSheet;

  const CreateMatchPageContent({
    super.key,
    required this.descriptionController,
    required this.matchDate,
    required this.matchTime,
    required this.addressController,
    required this.numberOfPlayersController,
    required this.createMatch,
    required this.openBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FloatingActionButton(
        onPressed: () {
          openBottomSheet(context);
        },
        backgroundColor: const Color(0xFF01BF6B),
        tooltip: 'Créer un match',
        child: const Icon(Icons.add),
      ),
    );
  }
}