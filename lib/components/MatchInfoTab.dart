// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pages/user_profile.dart';
import '../services/Match_service.dart';
import '../services/auth.service.dart';

class MatchInfoTab extends StatefulWidget {
  final String matchId;
  final String organizerId;
  final List<Map<String, dynamic>> participants;
  final String? selectedParticipantId;
  final ValueChanged<String?> onParticipantSelected;
  final VoidCallback onLeaveMatch;

  const MatchInfoTab({
    Key? key,
    required this.matchId,
    required this.organizerId,
    required this.participants,
    required this.selectedParticipantId,
    required this.onParticipantSelected,
    required this.onLeaveMatch,
  }) : super(key: key);

  @override
  _MatchInfoTabState createState() => _MatchInfoTabState();
}

class _MatchInfoTabState extends State<MatchInfoTab> {
  late Future<Map<String, dynamic>> _matchDetails;
  late Future<List<Map<String, dynamic>>> _matchPlayers;
  String? _refereeId;
  bool _isOrganizer = false;
  bool _isParticipant = false;
  String? _organizerUsername;

  @override
  void initState() {
    super.initState();
    _matchDetails = MatchService().getMatchDetails(widget.matchId);
    _matchPlayers = MatchService().getMatchPlayers(widget.matchId);
    _checkIfOrganizer();
    _checkIfParticipant();
  }

  void _checkIfOrganizer() async {
    final userInfo = await AuthService().getUserInfo();
    if (userInfo != null && userInfo['id'] == widget.organizerId) {
      setState(() {
        _isOrganizer = true;
      });
    }
  }

  void _checkIfParticipant() async {
    try {
      final userInfo = await AuthService().getUserInfo();
      if (userInfo != null && userInfo.containsKey('id')) {
        final players = await MatchService().getMatchPlayers(widget.matchId);
        final isParticipant =
            players.any((player) => player['id'] == userInfo['id']);
        setState(() {
          _isParticipant = isParticipant;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de la vérification de la participation au match',
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

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }

  String _formatTime(String time) {
    final DateTime parsedTime = DateTime.parse(time);
    return DateFormat('HH:mm').format(parsedTime);
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePages(userId: userId),
      ),
    );
  }

  void _assignReferee(String participantId) async {
    try {
      await MatchService().assignReferee(widget.matchId, participantId);
      setState(() {
        _refereeId = participantId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de l\'attribution de l\'arbitre',
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

  void _leaveMatch() async {
    try {
      await MatchService().leaveMatch(widget.matchId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vous avez quitté le match avec succès',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _isParticipant = false;
      });
      widget.onLeaveMatch(); // Appel du callback onLeaveMatch
      Navigator.pop(context); // Retourner à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de la tentative de quitter le match',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final buttonTextColor = isDarkTheme ? Colors.white : Colors.black;
    final buttonBorderColor = isDarkTheme ? Colors.white : Colors.black;

    return FutureBuilder<Map<String, dynamic>>(
      future: _matchDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Aucune donnée disponible'));
        } else {
          final matchDetails = snapshot.data!;
          final description = matchDetails['description'] ?? 'No Description';
          final address = matchDetails['address'] ?? 'No Address';
          final matchDate = matchDetails['date'] ?? 'No Date';
          final matchTime = matchDetails['time'] ?? 'No Time';
          _refereeId = matchDetails['referee_id'];
          final organizerUsername =
              matchDetails['organizer']['username'] ?? widget.organizerId;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Expanded(child: Text('Titre: $description')),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8.0),
                      Expanded(child: Text('Adresse: $address')),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.green),
                      const SizedBox(width: 8.0),
                      Expanded(child: Text('Date: ${_formatDate(matchDate)}')),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 8.0),
                      Expanded(child: Text('Heure: ${_formatTime(matchTime)}')),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text('Organisateur: $organizerUsername',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 16.0),
                  const Text('Participants:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _matchPlayers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                            'Pas encore de participants dans ce match.');
                      } else {
                        final participants = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: participants.map<Widget>((participant) {
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Row(
                                children: [
                                  Text(participant['username'] ?? 'Unknown'),
                                  if (participant['id'] == _refereeId)
                                    const Icon(Icons.star,
                                        color: Colors.yellow),
                                ],
                              ),
                              trailing: _isOrganizer
                                  ? ElevatedButton(
                                      onPressed: () =>
                                          _assignReferee(participant['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: buttonTextColor,
                                        side: BorderSide(
                                            color: buttonBorderColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: const Text('Nommer Arbitre'),
                                    )
                                  : null,
                              onTap: () =>
                                  _navigateToUserProfile(participant['id']),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  if (_isParticipant)
                    Center(
                      child: ElevatedButton(
                        onPressed: _leaveMatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Quitter le match'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
