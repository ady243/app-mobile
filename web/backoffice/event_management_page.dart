import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

const String baseUrl = "http://192.168.1.160:3003/api";

class EventManagementPage extends StatefulWidget {
  final String matchId;
  const EventManagementPage({required this.matchId, Key? key}) : super(key: key);

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final Dio _dio = Dio();
  final List<String> _eventTypes = ["But", "Passe décisive", "Carton jaune", "Carton rouge"];
  List<Map<String, dynamic>> _players = [];
  String? _selectedPlayerId;
  String? _selectedEventType;
  int? _minute;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchPlayers();
  }

  Future<void> _fetchMatchPlayers() async {
    try {
      final response = await _dio.get('$baseUrl/matches/${widget.matchId}');
      setState(() {
        _players = List<Map<String, dynamic>>.from(response.data['players'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des joueurs : $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createEvent() async {
    if (_selectedPlayerId == null || _selectedEventType == null || _minute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs doivent être renseignés.')),
      );
      return;
    }

    try {
      await _dio.post(
        '$baseUrl/api/analyst/events',
        data: {
          "match_id": widget.matchId,
          "analyst_id": "ID_ANALYSTE", // à remplacer !!!
          "player_id": _selectedPlayerId,
          "event_type": _selectedEventType,
          "minute": _minute,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création de l\'événement : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des événements"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Sélectionner un joueur :"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedPlayerId,
              items: _players.map((player) {
                return DropdownMenuItem<String>(
                  value: player['id'],
                  child: Text(player['username'] ?? "Joueur inconnu"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlayerId = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text("Type d'événement :"),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedEventType,
              items: _eventTypes.map((event) {
                return DropdownMenuItem<String>(
                  value: event,
                  child: Text(event),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text("Minute de l'événement :"),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Ex : 45"),
              onChanged: (value) {
                setState(() {
                  _minute = int.tryParse(value);
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _createEvent,
              child: const Text("Créer l'événement"),
            ),
          ],
        ),
      ),
    );
  }
}