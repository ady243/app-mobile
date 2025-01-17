import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/authweb_service.dart';
import '../widgets/sidebar.dart';
import '../utils/baseUrl.dart';

class EventManagementPage extends StatefulWidget {
  final String matchId;
  const EventManagementPage({required this.matchId, Key? key}) : super(key: key);

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final Dio _dio = Dio();
  final AuthWebService _authWebService = AuthWebService();
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
      final accessToken = await _authWebService.getToken();
      final response = await _dio.get(
        '$baseUrl/matchesPlayers/${widget.matchId}',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      setState(() {
        final uniquePlayers = <String, Map<String, dynamic>>{};
        for (var player in response.data['players'] ?? []) {
          uniquePlayers[player['id']] = player;
        }

        _players = uniquePlayers.values.toList();
        if (_players.isNotEmpty && _selectedPlayerId == null) {
          _selectedPlayerId = _players.first['id'];
        }
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

  Future<void> _fetchMatchEvents() async {
    try {
      final accessToken = await _authWebService.getToken();
      final response = await _dio.get(
        '$baseUrl/analyst/match/${widget.matchId}/events',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      setState(() {
        _events = List<Map<String, dynamic>>.from(response.data['events'] ?? []);
        _events.sort((a, b) => a['minute'].compareTo(b['minute']));
        _isEventsLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des événements : $e')),
      );
      setState(() {
        _isEventsLoading = false;
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
      final accessToken = await _authWebService.getToken();
      final userInfo = await _authWebService.getUserInfo();
      if (userInfo == null) throw Exception('Utilisateur introuvable');

      await _dio.post(
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé avec succès !')),
      );
      setState(() {
        _selectedPlayerId = null;
        _selectedEventType = null;
        _minute = null;
      });
      _fetchMatchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création de l\'événement : $e')),
      );
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      final accessToken = await _authWebService.getToken();
      await _dio.delete(
        '$baseUrl/analyst/events/$eventId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement supprimé avec succès !')),
      );
      _fetchMatchEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'événement : $e')),
      );
    }
  }

  void _editEvent(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) {
        String? editedPlayerId = event['player']['id'];
        String? editedEventType = event['event_type'];
        int? editedMinute = event['minute'];

        return AlertDialog(
          title: const Text('Modifier l\'événement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: editedPlayerId,
                items: _players.map((player) {
                  return DropdownMenuItem<String>(
                    value: player['id'],
                    child: Text(player['username'] ?? "Joueur inconnu"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    editedPlayerId = value;
                  });
                },
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: editedEventType,
                items: _eventTypes.map((event) {
                  return DropdownMenuItem<String>(
                    value: event,
                    child: Text(event),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    editedEventType = value;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Minute"),
                controller: TextEditingController(text: editedMinute.toString()),
                onChanged: (value) {
                  setState(() {
                    editedMinute = int.tryParse(value);
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final accessToken = await _authWebService.getToken();
                  await _dio.put(
                    '$baseUrl/analyst/events/${event['id']}',
                    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
                    data: {
                      "player_id": editedPlayerId,
                      "event_type": editedEventType,
                      "minute": editedMinute,
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Événement modifié avec succès !')),
                  );
                  Navigator.pop(context);
                  _fetchMatchEvents();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de la modification : $e')),
                  );
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/analystDashboard');
  }

  void _logout() async {
    await _authWebService.logout();
    Navigator.pushReplacementNamed(context, '/loginAnalyst');
  }

  Widget _buildEventList() {
    if (_isEventsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return const Center(child: Text("Aucun événement enregistré pour ce match."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return ListTile(
          title: Text("${event['event_type']} à la ${event['minute']}e minute"),
          subtitle: Text("Joueur : ${event['player']['username']}"),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(
            onLogout: _logout,
            onNavigateDashboard: _navigateToDashboard,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const Text(
                    'Gestion des événements',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sélectionner un joueur :",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: _players.any((player) => player['id'] == _selectedPlayerId)
                              ? _selectedPlayerId
                              : null,
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
                        const Text(
                          "Type d'événement :",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                        const Text(
                          "Minute de l'événement :",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                        _buildEventList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
