import 'package:flutter/material.dart';
import 'package:teamup/services/friend_service.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chat_page.dart';
import 'user_profile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> _friends = [];
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        _friends = friends;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userInfo = await _authService.getUserInfo();
      setState(() {
        _currentUserId = userInfo?['id'];
      });
    } catch (e) {
      // ignore: empty_catches
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _friends.isEmpty
                    ? const Center(
                        child: Text(
                          'Vous n\'avez pas encore des amis à envoyer un message.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: friend['profile_picture'] != null &&
                                        friend['profile_picture'].isNotEmpty
                                    ? Image.network(friend['profile_picture'])
                                    : Text(friend['username'][0]),
                              ),
                              title: Row(
                                children: [
                                  Text(friend['username']),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserProfilePages(userId: friend['id']),
                                  ),
                                );
                              },
                              trailing: IconButton(
                                icon: const FaIcon(FontAwesomeIcons.comment),
                                onPressed: () {
                                  if (_currentUserId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatPage(
                                          friendName: friend['username'],
                                          senderId: _currentUserId!,
                                          receiverId: friend['id'],
                                          receiverFcmToken: friend['fcm_token'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Current user ID is null');
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
