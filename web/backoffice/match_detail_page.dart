import 'package:flutter/material.dart';
import 'package:teamup/services/auth.service.dart';
import '../services/event_service.dart';

class MatchDetailPage extends StatefulWidget {
  final String matchId;
  const MatchDetailPage({required this.matchId, super.key});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final _eventTypeCtrl = TextEditingController();
  final _playerCtrl = TextEditingController();
  final _minuteCtrl = TextEditingController();
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    final authService = AuthService(); // Idéalement: gestion globale
    _eventService = EventService(authService);
  }

  Future<void> _addEvent() async {
    final eventType = _eventTypeCtrl.text;
    final player = _playerCtrl.text;
    final minute = int.tryParse(_minuteCtrl.text) ?? 0;

    try {
      await _eventService.addEventToMatch(widget.matchId, eventType, player, minute);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evénement ajouté !')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'ajout d\'un événement')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match: ${widget.matchId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventTypeCtrl,
              decoration: const InputDecoration(labelText: 'Type d\'événement (ex: goal, yellow_card)'),
            ),
            TextField(
              controller: _playerCtrl,
              decoration: const InputDecoration(labelText: 'Joueur concerné'),
            ),
            TextField(
              controller: _minuteCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Minute de l\'événement'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addEvent,
              child: const Text('Ajouter événement'),
            )
          ],
        ),
      ),
    );
  }
}
