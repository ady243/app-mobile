import 'package:flutter/material.dart';
import '../services/MatchService.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  const MatchDetailsPage({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> {
  final MatchService _matchService = MatchService();
  Map<String, dynamic>? _matchDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  void _fetchMatchDetails() async {
    try {
      final details = await _matchService.getMatchWithPlayers(widget.matchId);
      setState(() {
        _matchDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching match details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Match'),
        backgroundColor: const Color(0xFF01BF6B),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matchDetails == null || _matchDetails!.isEmpty
          ? const Center(child: Text('Aucun détail disponible'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formation: ${_matchDetails!['formations'] != null && _matchDetails!['formations'].isNotEmpty ? _matchDetails!['formations'][0] : 'Non spécifié'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildFieldLayout(),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildFieldLayout() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/terrain.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        ..._buildPlayersOnField(),
      ],
    );
  }


  List<Widget> _buildPlayersOnField() {
    if (_matchDetails == null || _matchDetails!['players'] == null) {
      return [];
    }

    final players = _matchDetails!['players'];
    List<Widget> playerWidgets = [];

    // Exemples de positionnement selon une formation 4-3-3
    for (int i = 0; i < players.length; i++) {
      var player = players[i];
      String role = player['role'].toLowerCase();

      // Déterminer la position basée sur le rôle du joueur
      Offset position;
      switch (role) {
        case 'goalkeeper':
          position = Offset(0.5, 0.9);
          break;
        case 'defender':
          position = Offset(0.15 + (0.2 * (i % 4)), 0.7);
          break;
        case 'midfielder':
          position = Offset(0.25 + (0.25 * (i % 3)), 0.5);
          break;
        case 'forward':
          position = Offset(0.4 + (0.2 * (i % 3)), 0.3);
          break;
        default:
          position = Offset(0.5, 0.5);
      }

      playerWidgets.add(Positioned(
        left: MediaQuery.of(context).size.width * position.dx - 20,
        top: MediaQuery.of(context).size.height * position.dy - 20,
        child: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(
            player['username'][0],
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ));
    }

    return playerWidgets;
  }
}

// Custom painter pour dessiner le terrain
class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Centre du terrain
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
