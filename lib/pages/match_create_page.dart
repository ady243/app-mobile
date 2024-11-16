import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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

  Future<List<Prediction>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&components=country:fr';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> predictions = data['predictions'];
          return predictions.map((json) => Prediction.fromJson(json)).toList();
        }
      }
      return [];
    } catch (error) {
      print('Erreur lors de la récupération des suggestions : $error');
      return [];
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
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        if (_addressController.text.length >= 5) {
                          setState(() {
                            _addressQuery = _addressController.text;
                          });
                        }
                      },
                    ),
                  ),
                  onChanged: (query) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 800), () {
                      setState(() {
                        _addressQuery = query;
                      });
                    });
                  },
                ),
                if (_addressQuery.isNotEmpty)
                  FutureBuilder<List<Prediction>>(
                    future: getSuggestions(_addressQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Erreur de chargement des suggestions');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Aucune suggestion trouvée');
                      } else {
                        final suggestions = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            final prediction = suggestions[index];
                            return ListTile(
                              title: Text(prediction.description ?? ''),
                              onTap: () {
                                setState(() {
                                  _addressController.text = prediction.description ?? '';
                                  _addressQuery = '';
                                });
                              },
                            );
                          },
                        );
                      }
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: const Text(
            'Créer un match',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF01BF6B),
        ),
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
