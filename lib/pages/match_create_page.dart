import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:teamup/components/CreateMatchForm.dart';
import 'package:teamup/components/CreateMatchPageContent.dart';
import 'dart:convert';
import 'dart:async';
import '../services/MatchService.dart';
import 'my_match.dart';
import 'package:provider/provider.dart';
import '../components/theme_provider.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({Key? key}) : super(key: key);

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  TimeOfDay? _endTime;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberOfPlayersController = TextEditingController();
  final MatchService _matchService = MatchService();
  final String _googleApiKey = 'AIzaSyAdNnq6m3qBSXKlKK5gbQJMdbd22OWeHCg';

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _descriptionController.dispose();
    _addressController.dispose();
    _numberOfPlayersController.dispose();
    super.dispose();
  }

  Future<void> _createMatch(DateTime? matchDate, TimeOfDay? matchTime, TimeOfDay? endTime) async {
    print('Creating match with:');
    print('Date: $matchDate');
    print('Start Time: $matchTime');
    print('End Time: $endTime');

    if (matchDate == null || matchTime == null || endTime == null) {
      Fluttertoast.showToast(msg: 'Veuillez sélectionner une date, une heure de début et une heure de fin.');
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

    // Formatage de la date et des heures
    final String matchDateStr = DateFormat('yyyy-MM-dd').format(matchDate);
    final String matchTimeStr = DateFormat('HH:mm:ss').format(DateTime(0, 1, 1, matchTime!.hour, matchTime.minute));
    final String endTimeStr = DateFormat('HH:mm:ss').format(DateTime(0, 1, 1, endTime!.hour, endTime.minute));

    Map<String, dynamic> matchData = {
      'description': _descriptionController.text,
      'match_date': matchDateStr,
      'match_time': matchTimeStr,
      'end_time': endTimeStr,
      'address': _addressController.text,
      'number_of_players': numberOfPlayers,
    };

    try {
      await _matchService.createMatch(matchData);
      Fluttertoast.showToast(msg: 'Match créé avec succès !');
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur lors de la création du match : $e');
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      await _matchService.deleteMatch(matchId);
      Fluttertoast.showToast(msg: 'Match supprimé avec succès !');
      setState(() {
        // Actualiser la liste des matchs après suppression
        _fetchMatches();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur lors de la suppression du match : $e');
    }
  }

  Future<void> _fetchMatches() async {
    // Implémentez la logique pour récupérer les matchs créés par l'utilisateur
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
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
            child: CreateMatchForm(
              descriptionController: _descriptionController,
              matchDate: _matchDate,
              matchTime: _matchTime,
              endTime: _endTime,
              addressController: _addressController,
              numberOfPlayersController: _numberOfPlayersController,
              createMatch: _createMatch,
              autoCompleteAddress: _autoCompleteAddress,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mes Matchs',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mes matches créés'),
              Tab(text: 'Créer un match'),
            ],
            indicatorColor: Colors.green,
            labelColor: Color(0xFF01BF6B),
            unselectedLabelColor: Colors.white,
          ),
          centerTitle: true,
          backgroundColor: themeProvider.primaryColor,
        ),
        body: TabBarView(
          children: [
            MyCreatedMatchesPage(
              onDeleteMatch: _deleteMatch,
            ),
            CreateMatchPageContent(
              openBottomSheet: _openBottomSheet,
            ),
          ],
        ),
      ),
    );
  }
}