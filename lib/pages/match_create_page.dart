import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:teamup/components/CreateMatchForm.dart';
import 'package:teamup/components/CreateMatchPageContent.dart';
import 'dart:convert';
import 'dart:async';
import '../services/Match_service.dart';
import 'my_match.dart';

class CreateMatchPage extends StatefulWidget {
  const CreateMatchPage({super.key});

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _matchDate;
  TimeOfDay? _matchTime;
  TimeOfDay? _endTime;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _numberOfPlayersController =
      TextEditingController();
  final MatchService _matchService = MatchService();
  final String _googleApiKey = 'AIzaSyAdNnq6m3qBSXKlKK5gbQJMdbd22OWeHCg';

  Timer? _debounce;
  bool _isLoading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _descriptionController.dispose();
    _addressController.dispose();
    _numberOfPlayersController.dispose();
    super.dispose();
  }

  Future<void> _createMatch(
      DateTime? matchDate, TimeOfDay? matchTime, TimeOfDay? endTime) async {
    if (matchDate == null || matchTime == null || endTime == null) {
      Fluttertoast.showToast(
          msg:
              'Veuillez sélectionner une date, une heure de début et une heure de fin.');
      return;
    }

    if (_descriptionController.text.isEmpty ||
        _addressController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Veuillez remplir tous les champs obligatoires.');
      return;
    }

    final int? numberOfPlayers = int.tryParse(_numberOfPlayersController.text);
    if (numberOfPlayers == null || numberOfPlayers <= 0) {
      Fluttertoast.showToast(
          msg: 'Veuillez entrer un nombre valide de joueurs.');
      return;
    }

    final String matchDateStr = DateFormat('yyyy-MM-dd').format(matchDate);
    final String matchTimeStr = DateFormat('HH:mm:ss')
        .format(DateTime(0, 1, 1, matchTime.hour, matchTime.minute));
    final String endTimeStr = DateFormat('HH:mm:ss')
        .format(DateTime(0, 1, 1, endTime.hour, endTime.minute));

    Map<String, dynamic> matchData = {
      'description': _descriptionController.text,
      'match_date': matchDateStr,
      'match_time': matchTimeStr,
      'end_time': endTimeStr,
      'address': _addressController.text,
      'number_of_players': numberOfPlayers,
    };

    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _matchService.createMatch(matchData);
      Fluttertoast.showToast(msg: 'Match créé avec succès !');
      Navigator.of(context).pop(); // Close the loader dialog
      Navigator.of(context).pop(); // Close the create match page
    } catch (e) {
      Navigator.of(context).pop(); // Close the loader dialog
      Fluttertoast.showToast(msg: 'Erreur lors de la création du match : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    try {
      await _matchService.deleteMatch(matchId);
      Fluttertoast.showToast(msg: 'Match supprimé avec succès !');
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de la suppression du match',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de la recherche d\'adresse',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 10),
            const TabBar(
              tabs: [
                Tab(text: 'Mes matches créés'),
                Tab(text: 'Créer un match'),
              ],
              indicatorColor: Colors.green,
              labelColor: Color(0xFF01BF6B),
              unselectedLabelColor: Colors.green,
            ),
            Expanded(
              child: TabBarView(
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
          ],
        ),
      ),
    );
  }
}
