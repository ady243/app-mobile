import 'package:flutter/material.dart';
import '../services/ChatService.dart';
import '../services/auth.service.dart';

class ChatTab extends StatefulWidget {
  final String matchId;

  const ChatTab({super.key, required this.matchId});

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isPlayerInMatch = false;

  @override
  void initState() {
    super.initState();
    _checkPlayerInMatch();
    _fetchMessages();
  }

  void _checkPlayerInMatch() async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null || !userInfo.containsKey('id')) {
        throw Exception('Impossible de récupérer l\'ID utilisateur');
      }
      final userId = userInfo['id'];
      final isPlayerInMatch = await _chatService.isPlayerInMatch(widget.matchId, userId);
      setState(() {
        _isPlayerInMatch = isPlayerInMatch;
      });
    } catch (e) {
      print('Error checking player in match: $e');
      setState(() {
        _isPlayerInMatch = false;
      });
    }
  }

  void _fetchMessages() async {
    try {
      final messages = await _chatService.getMessages(widget.matchId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null || !userInfo.containsKey('id')) {
      throw Exception('Impossible de récupérer l\'ID utilisateur');
    }
    final userId = userInfo['id'];
    final message = _messageController.text;

    if (message.isEmpty) {
      return;
    }

    if (!_isPlayerInMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez rejoindre le match pour envoyer des messages.')),
      );
      return;
    }

    try {
      await _chatService.sendMessage(widget.matchId, userId, message);
      _messageController.clear();
      _fetchMessages();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    message['username'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(message['username']),
                subtitle: Text(message['message']),
                trailing: Text(
                  message['timestamp'],
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}