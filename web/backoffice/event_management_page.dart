import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:teamup/services/auth.service.dart';

const String baseUrl = "http://localhost:3003/api";

class EventManagementPage extends StatefulWidget {
  final String matchId;
  const EventManagementPage({required this.matchId, Key? key}) : super(key: key);

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  final List<String> _eventTypes = ["But", "Passe décisive", "Carton jaune", "Carton rouge"];
  List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _events = [];
  String? _selectedPlayerId;
  String? _selectedEventType;
  int? _minute;
  bool _isLoading = true;
  bool _isEventsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchPlayers();
    _fetchMatchEvents();
  }

  Future<void> _fetchMatchPlayers() async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/matchesPlayers/${widget.matchId}',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (mounted) {
        setState(() {
          _players = List<Map<String, dynamic>>.from(response.data['players'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des joueurs : $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMatchEvents() async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.get(
        '$baseUrl/analyst/match/${widget.matchId}/events',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (mounted) {
        setState(() {
          _events = List<Map<String, dynamic>>.from(response.data['events'] ?? []);
          _events.sort((a, b) => a['minute'].compareTo(b['minute']));
          _isEventsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des événements : $e')),
        );
        setState(() {
          _isEventsLoading = false;
        });
      }
    }
  }

  Future<void> _createEvent() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null || !userInfo.containsKey('id')) {
      throw Exception('Impossible de récupérer l\'ID utilisateur');
    }
    if (_selectedPlayerId == null || _selectedEventType == null || _minute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs doivent être renseignés.')),
      );
      return;
    }

    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.post(
        '$baseUrl/analyst/events',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: {
          "match_id": widget.matchId,
          "analyst_id": userInfo['id'],
          "player_id": _selectedPlayerId,
          "event_type": _selectedEventType,
          "minute": _minute,
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement créé avec succès !')),
        );
        setState(() {
          _selectedPlayerId = null;
          _selectedEventType = null;
          _minute = null;
        });
        _fetchMatchEvents();
      } else {
        throw Exception("Erreur lors de la création de l'événement.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création de l\'événement : $e')),
      );
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.delete(
        '$baseUrl/analyst/events/$eventId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement supprimé avec succès !')),
        );
        _fetchMatchEvents();
      } else {
        throw Exception("Erreur lors de la suppression de l'événement.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'événement : $e')),
      );
    }
  }

  void _editEvent(Map<String, dynamic> event) {
    String? selectedEventType = event['event_type'];
    int? minute = event['minute'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier l'événement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: selectedEventType,
                items: _eventTypes.map((eventType) {
                  return DropdownMenuItem<String>(
                    value: eventType,
                    child: Text(eventType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEventType = value;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Minute"),
                controller: TextEditingController(text: minute.toString()),
                onChanged: (value) {
                  minute = int.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateEvent(event['id'], selectedEventType, minute);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateEvent(String eventId, String? eventType, int? minute) async {
    if (eventType == null || minute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs doivent être renseignés.')),
      );
      return;
    }

    try {
      final accessToken = await _authService.getToken();
      final response = await _dio.put(
        '$baseUrl/analyst/events/$eventId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        data: {
          "event_type": eventType,
          "minute": minute,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement modifié avec succès !')),
        );
        _fetchMatchEvents();
      } else {
        throw Exception("Erreur lors de la modification de l'événement.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la modification de l\'événement : $e')),
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
          : SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 30.0),
              const Text(
                "Événements enregistrés :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _isEventsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                  ? const Text("Aucun événement enregistré pour ce match.")
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  return ListTile(
                    title: Text("Joueur : ${event['player']['username']}"),
                    subtitle: Text("${event['event_type']} à la ${event['minute']}e minute"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editEvent(event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
