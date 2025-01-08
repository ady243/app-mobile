import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teamup/models/message.dart';


import '../services/friendChat_service.dart';

class ChatPage extends StatefulWidget {
  final String friendName;
  final String senderId;
  final String receiverId;
  final String receiverFcmToken;

  const ChatPage({
    super.key,
    required this.friendName,
    required this.senderId,
    required this.receiverId,
    required this.receiverFcmToken,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final FriendChatService _friendChatService = FriendChatService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      List<Message> messages = await _friendChatService.getMessages(
          widget.senderId, widget.receiverId);
      setState(() {
        _messages.addAll(messages.map((message) => {
          'text': message.content,
          'isSentByMe': message.senderId == widget.senderId,
          'createdAt': message.createdAt,
        }));
      });
    } catch (e) {
      // ignore: empty_catches
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final newMessage = Message(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
        content: _messageController.text,
        createdAt: DateTime.now(),
      );

      try {
        await _friendChatService.sendMessage(newMessage);
        setState(() {
          _messages.add({
            'text': _messageController.text,
            'isSentByMe': true,
            'createdAt': newMessage.createdAt,
          });
          _messageController.clear();
        });
      // ignore: empty_catches
      } catch (e) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversation avec ${widget.friendName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final formattedDate =
                DateFormat('dd/MM/yyyy HH:mm').format(message['createdAt']);
                return Align(
                  alignment: message['isSentByMe']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: message['isSentByMe']
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            color: message['isSentByMe']
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: message['isSentByMe']
                                ? Colors.white70
                                : Colors.black54,
                            fontSize: 10.0,
                          ),
                        ),
                      ],
                    ),
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
                    decoration: InputDecoration(
                      hintText: 'Entrez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blueAccent,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}