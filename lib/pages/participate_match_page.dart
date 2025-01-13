import 'package:flutter/material.dart';
import 'package:teamup/services/Match_service.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:intl/intl.dart';
import 'MatchDetailsPage.dart';

class ParticipatedMatchesPage extends StatefulWidget {
  const ParticipatedMatchesPage({super.key});

  @override
  _ParticipatedMatchesPageState createState() =>
      _ParticipatedMatchesPageState();
}

class _ParticipatedMatchesPageState extends State<ParticipatedMatchesPage> {
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _participatedMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchParticipatedMatches();
  }

  void _fetchParticipatedMatches() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo != null && userInfo.containsKey('id')) {
      final userId = userInfo['id'];
      try {
        final participatedMatches =
            await _matchService.getMatchesByPlayerID(userId);
        setState(() {
          _participatedMatches = participatedMatches;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Erreur lors de la récupération des matchs participés: $e');
      }
    }
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate != null) {
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    }
    return date;
  }

  String _formatTime(String time) {
    final parsedTime = DateTime.tryParse(time);
    if (parsedTime != null) {
      return DateFormat('HH:mm').format(parsedTime);
    }
    return time;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _navigateToMatchDetails(String matchId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(matchId: matchId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _participatedMatches.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: _participatedMatches.length,
                itemBuilder: (context, index) {
                  final match = _participatedMatches[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: _getStatusColor(match['status'] ?? 'unknown'),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        match['description'] ?? 'No Description',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(_formatDate(match['date'])),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 8),
                              Text(_formatTime(match['time'])),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  match['address'] ?? 'No Address',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.info, size: 16),
                              const SizedBox(width: 8),
                              Text(match['status'] ?? 'No Status'),
                            ],
                          ),
                        ],
                      ),
                      onTap: () =>
                          _navigateToMatchDetails(match['id'].toString()),
                    ),
                  );
                },
              );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/image_empty.png',
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun match auquel vous avez participé',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vous n\'avez participé à aucun match.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
