import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/authweb_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.green[800],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logos/grey_logo.png',
                        height: 60,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'TeamUp',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Analyste',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sports_soccer, color: Colors.white),
                  title: const Text(
                    'Gestion des matchs',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {},
                ),
                const Divider(color: Colors.white54),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    _authWebService.logout();
                    Navigator.pushReplacementNamed(context, '/loginAnalyst');
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Gestion des événements',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                              title: Text(
                                  "Joueur : ${event['player']['username']}"),
                              subtitle: Text(
                                  "${event['event_type']} à la ${event['minute']}e minute"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {},
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
