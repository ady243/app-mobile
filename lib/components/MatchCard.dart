import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatefulWidget {
  final String description;
  final String matchDate;
  final String matchTime;
  final String endTime;
  final String address;
  final String status;
  final int numberOfPlayers;
  final bool isJoined;
  final bool isOrganizer;
  final VoidCallback? onTap;
  final VoidCallback onJoin;

  const MatchCard({
    Key? key,
    required this.description,
    required this.matchDate,
    required this.matchTime,
    required this.endTime,
    required this.address,
    required this.status,
    required this.numberOfPlayers,
    required this.isJoined,
    required this.isOrganizer,
    this.onTap,
    required this.onJoin,
  }) : super(key: key);

  @override
  _MatchCardState createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  late DateTime _matchDateTime;
  late DateTime _endDateTime;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _initializeDateTime();
    _status = widget.status;
  }

  void _initializeDateTime() {
    try {
      print('Parsing matchDate: ${widget.matchDate}');
      print('Parsing matchTime: ${widget.matchTime}');
      print('Parsing endTime: ${widget.endTime}');
      
      _matchDateTime = DateTime.parse('${widget.matchDate.split('T')[0]}T${widget.matchTime.split('T')[1]}');
      _endDateTime = widget.endTime.isNotEmpty
          ? DateTime.parse('${widget.matchDate.split('T')[0]}T${widget.endTime.split('T')[1]}')
          : _matchDateTime.add(Duration(hours: 1)); // Default to 1 hour after match start if endTime is empty
      
      print('Parsed matchDateTime: $_matchDateTime');
      print('Parsed endDateTime: $_endDateTime');
    } catch (e) {
      print('Erreur lors de la conversion de la date et de l\'heure: $e');
      _matchDateTime = DateTime.now(); // Valeur par défaut en cas d'erreur
      _endDateTime = DateTime.now(); // Valeur par défaut en cas d'erreur
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'ongoing':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming':
        return 'À venir';
      case 'ongoing':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'expired':
        return 'Expiré';
      default:
        return 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('dd MMM yyyy').format(_matchDateTime);
    final String formattedStartTime = DateFormat('HH:mm').format(_matchDateTime);
    final String formattedEndTime = DateFormat('HH:mm').format(_endDateTime);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/football.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        '$formattedStartTime - $formattedEndTime',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        widget.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        widget.numberOfPlayers.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(_getStatusIcon(_status), color: _getStatusColor(_status)),
                      const SizedBox(width: 5),
                      Text(
                        _getStatusText(_status),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_status != 'completed')
                    Align(
                      alignment: Alignment.centerRight,
                      child: widget.isOrganizer
                          ? ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text(
                                'Vous êtes le créateur',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: (widget.isJoined || _status == 'ongoing' || _status == 'completed') ? null : widget.onJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (widget.isJoined || _status == 'ongoing' || _status == 'completed') ? Colors.grey : Colors.green,
                              ),
                              child: Text(
                                widget.isJoined ? 'Vous avez rejoint' : 'Réjoindre le match',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
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