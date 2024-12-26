import 'package:flutter/material.dart';
import '../components/TopBarDetail.dart';
import '../components/MatchInfoTab.dart';
import '../components/ChatTab.dart';
import '../components/AiSuggestionOverlay.dart';
import '../services/MatchService.dart';
import '../services/ChatService.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';
import '../models/Match.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  const MatchDetailsPage({super.key, required this.matchId});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage> with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _showAiResponse = false;
  String _aiResponse = 'Laisse moi te proposer une formation ... ...';
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _hasNewMessages = false;
  final ChatService _chatService = ChatService();
  String _organizerId = '';
  List<Map<String, dynamic>> _participants = [];
  String? _selectedParticipantId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _fetchMatchDetails();
    _fetchParticipants();
    _checkForNewMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchMatchDetails() async {
    try {
      final matchService = MatchService();
      final matchDetailsJson = await matchService.getMatchDetails(widget.matchId);
      print('Match details fetched: $matchDetailsJson'); // Ajoutez ce log pour vérifier les données JSON
      final matchDetails = Match.fromJson(matchDetailsJson);
      print('Organizer ID: ${matchDetails.organizer.id}'); // Ajoutez ce log pour vérifier l'ID de l'organisateur
      setState(() {
        _organizerId = matchDetails.organizer.id;
      });
    } catch (e) {
      print('Erreur lors de la récupération des détails du match: $e');
    }
  }

  void _fetchParticipants() async {
    try {
      final matchService = MatchService();
      final participants = await matchService.getMatchPlayers(widget.matchId);
      setState(() {
        _participants = participants;
      });
    } catch (e) {
      print('Erreur lors de la récupération des participants: $e');
    }
  }

  void _assignReferee(String participantId) async {
    try {
      final matchService = MatchService();
      await matchService.assignReferee(widget.matchId, participantId);
      setState(() {
        _selectedParticipantId = participantId;
      });
    } catch (e) {
      print('Erreur lors de l\'attribution de l\'arbitre: $e');
    }
  }

  void _checkForNewMessages() async {
    bool hasNew = await _chatService.hasNewMessages(widget.matchId);
    setState(() {
      _hasNewMessages = hasNew;
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
      if (index == 1) {
        _hasNewMessages = false;
        _chatService.markMessagesAsRead(widget.matchId);
      }
    });
  }

  String _cleanAiResponse(String response) {
    return response.replaceAll('*', '').replaceAll('###', '').replaceAll('####', '').replaceAll('#', '');
  }

  Future<void> _fetchAndShowAiResponse() async {
    try {
      final matchService = MatchService();
      final aiData = await matchService.isAi(widget.matchId);
      if (aiData.containsKey('formation')) {
        setState(() {
          _aiResponse = _cleanAiResponse(aiData['formation'].join('\n'));
          _showAiResponse = true;
        });
        _controller.forward();
      } else {
        throw Exception("Pas de formation AI trouvée dans la réponse.");
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Erreur lors de la récupération de la suggestion d'IA.";
        _showAiResponse = true;
      });
      _controller.forward();
    }
  }

  void _closeAiResponse() {
    setState(() => _showAiResponse = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du Match',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              TopBarDetail(
                currentIndex: _currentTabIndex,
                onTabSelected: _onTabSelected,
                hasNewMessages: _hasNewMessages,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    MatchInfoTab(
                      matchId: widget.matchId,
                      organizerId: _organizerId,
                      participants: _participants,
                      selectedParticipantId: _selectedParticipantId,
                      onParticipantSelected: (String? newValue) {
                        setState(() {
                          _selectedParticipantId = newValue;
                        });
                        if (newValue != null) {
                          _assignReferee(newValue);
                        }
                      },
                    ),
                    ChatTab(matchId: widget.matchId),
                  ],
                ),
              ),
            ],
          ),
          if (_showAiResponse)
            AiSuggestionOverlay(
              aiResponse: _aiResponse,
              onClose: _closeAiResponse,
              offsetAnimation: _offsetAnimation,
            ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: _fetchAndShowAiResponse,
              backgroundColor: const Color(0xFFFFFFFF),
              child: Image.asset('assets/images/ia.png'),
            )
          : null,
    );
  }
}