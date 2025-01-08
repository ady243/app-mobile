import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teamup/pages/user_profile.dart';
import 'package:teamup/services/Chat_service.dart';
import '../services/Match_service.dart';
import '../services/auth.service.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import '../components/theme_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatTab extends StatefulWidget {
  final String matchId;

  const ChatTab({super.key, required this.matchId});

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final ChatService _chatService = ChatService();
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _initializeWebSocket() {
    _channel = IOWebSocketChannel.connect('wss://api-teamup.onrender.com/ws');
    _channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      if (decodedMessage['matchId'] == widget.matchId) {
        setState(() {
          _messages.add(decodedMessage);
        });
        _scrollToBottom();
      }
    });
  }

  void _getCurrentUserId() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo != null && userInfo.containsKey('id')) {
      setState(() {
        _currentUserId = userInfo['id'];
      });
    }

    final matchDetails = await _matchService.getMatchDetails(widget.matchId);
    if (matchDetails != null && matchDetails.containsKey('organizer_id')) {
      setState(() {});
    }
  }

  void _fetchMessages() async {
    try {
      final messages = await _chatService.getMessages(widget.matchId);
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      // Handle error
    }
  }

  void _sendMessage() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Impossible de récupérer l\'ID utilisateur')),
      );
      return;
    }

    final message = _messageController.text;

    if (message.isEmpty) {
      return;
    }

    try {
      await _chatService.sendMessage(widget.matchId, _currentUserId!, message);
      _messageController.clear();
      _channel.sink.add(jsonEncode({
        'matchId': widget.matchId,
        'userId': _currentUserId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vous ne pouvez pas envoyer de message sans être inscrit dans ce match',
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePages(userId: userId),
      ),
    );
  }

  Color _getUserColor(String userId) {
    final colors = [
      Colors.red[100],
      Colors.green[100],
      Colors.blue[100],
      Colors.yellow[100],
      Colors.purple[100],
      Colors.orange[100],
      Colors.teal[100],
      Colors.pink[100],
      Colors.brown[100],
    ];
    final index = userId.hashCode % colors.length;
    return colors[index]!;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message['userId'] == _currentUserId;
                return _buildMessageBubble(
                    message, isCurrentUser, themeProvider);
              },
            ),
          ),
          if (_currentUserId != null)
            _buildMessageInput(theme, themeProvider)
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  'Vous ne pouvez pas envoyer de messages sans être connecté.'),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isCurrentUser,
      ThemeProvider themeProvider) {
    final username = message['username'] ?? 'Utilisateur';
    final userId = message['userId'] ?? '';
    final messageText = message['message'] ?? '';
    final timestamp = message['timestamp'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) _buildAvatar(userId, username),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 0),
                  bottomRight: Radius.circular(isCurrentUser ? 0 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    messageText,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isCurrentUser) _buildAvatar(userId, username),
        ],
      ),
    );
  }

  Widget _buildAvatar(String userId, String username) {
    return GestureDetector(
      onTap: () => _navigateToUserProfile(userId),
      child: CircleAvatar(
        backgroundColor: const Color(0xFF01BF6B),
        child: Text(
          username[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: _currentUserId == null
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  'Vous ne pouvez pas envoyer de messages sans être connecté.'),
            )
          : Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Entrez votre message...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: themeProvider.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    final dateTime = DateTime.parse(timestamp);
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
}