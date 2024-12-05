import 'package:flutter/material.dart';
import '../components/TopBar.dart';
import '../components/MatchInfoTab.dart';
import '../components/ChatTab.dart';
import '../components/AiSuggestionOverlay.dart';
import '../services/MatchService.dart';
import '../services/ChatService.dart';
import '../components/theme_provider.dart';
import 'package:provider/provider.dart';

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
    _checkForNewMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              TopBar(
                currentIndex: _currentTabIndex,
                onTabSelected: _onTabSelected,
                hasNewMessages: _hasNewMessages,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    MatchInfoTab(matchId: widget.matchId),
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