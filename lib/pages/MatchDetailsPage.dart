import 'package:flutter/material.dart';
import 'package:teamup/services/Chat_service.dart';
import '../components/TopBarDetail.dart';
import '../components/MatchInfoTab.dart';
import '../components/ChatTab.dart';
import '../components/AiSuggestionOverlay.dart';
import '../services/Match_service.dart';
import '../services/auth.service.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';
import '../models/Match.dart';

class MatchDetailsPage extends StatefulWidget {
  final String matchId;

  const MatchDetailsPage({super.key, required this.matchId});

  @override
  _MatchDetailsPageState createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  bool _showAiResponse = false;
  String _aiResponse = 'Laisse moi te proposer une formation ... ...';
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _hasNewMessages = false;
  final ChatService _chatService = ChatService();
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  String _organizerId = '';
  List<Map<String, dynamic>> _participants = [];
  String? _selectedParticipantId;
  String? _currentUserId;
  bool _isLoading = true;
  bool _isAiLoading = false; // Nouvel état pour le chargement de l'IA

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
    _fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      _fetchMatchDetails(),
      _fetchParticipants(),
      _fetchCurrentUser(),
      _checkForNewMessages(),
    ]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMatchDetails() async {
    try {
      final matchDetailsJson =
      await _matchService.getMatchDetails(widget.matchId);
      print('Match details fetched: $matchDetailsJson');
      final matchDetails = Match.fromJson(matchDetailsJson);
      print('Organizer ID: ${matchDetails.organizer.id}');
      setState(() {
        _organizerId = matchDetails.organizer.id;
      });
    } catch (e) {
      print('Erreur lors de la récupération des détails du match: $e');
    }
  }

  Future<void> _fetchParticipants() async {
    try {
      final participants = await _matchService.getMatchPlayers(widget.matchId);
      setState(() {
        _participants = participants;
      });
    } catch (e) {
      print('Erreur lors de la récupération des participants: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userInfo = await _authService.getUserInfo();
      setState(() {
        _currentUserId = userInfo?['id'];
      });
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur: $e');
    }
  }

  Future<void> _checkForNewMessages() async {
    bool hasNew = await _chatService.hasNewMessages(widget.matchId);
    setState(() {
      _hasNewMessages = hasNew;
    });
  }

  void _assignReferee(String participantId) async {
    try {
      await _matchService.assignReferee(widget.matchId, participantId);
      setState(() {
        _selectedParticipantId = participantId;
      });
    } catch (e) {
      print('Erreur lors de l\'attribution de l\'arbitre: $e');
    }
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
    return response
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('####', '')
        .replaceAll('#', '');
  }

  Future<void> _fetchAndShowAiResponse() async {
    setState(() {
      _isAiLoading = true; // Démarre le chargement de l'IA
    });
    try {
      final aiData = await _matchService.isAi(widget.matchId);
      if (aiData.containsKey('formation')) {
        setState(() {
          _aiResponse = _cleanAiResponse(aiData['formation'].join('\n'));
          _showAiResponse = true;
          _isAiLoading = false; // Arrête le chargement de l'IA
        });
        _controller.forward();
      } else {
        throw Exception("Pas de formation AI trouvée dans la réponse.");
      }
    } catch (e) {
      setState(() {
        _aiResponse = "Erreur lors de la récupération de la suggestion d'IA.";
        _showAiResponse = true;
        _isAiLoading = false; // Arrête le chargement de l'IA
      });
      _controller.forward();
    }
  }

  void _closeAiResponse() {
    setState(() => _showAiResponse = false);
    _controller.reverse();
  }

  void _handleLeaveMatch() async {
    try {
      await _matchService.leaveMatch(widget.matchId);
      setState(() {
        _participants.removeWhere(
                (participant) => participant['id'] == _selectedParticipantId);
        _selectedParticipantId = null;
      });
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
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Chargement des données...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
          : Stack(
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
                      onLeaveMatch: _organizerId == _currentUserId
                          ? () {}
                          : _handleLeaveMatch,
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
        onPressed: _isAiLoading ? null : _fetchAndShowAiResponse,
        backgroundColor: const Color(0xFFFFFFFF),
        child: _isAiLoading
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        )
            : Image.asset('assets/images/ia.png'),
      )
          : null,
    );
  }
}
