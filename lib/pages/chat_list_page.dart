import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _fetchCurrentUser();
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        _friends = friends;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userInfo = await _authService.getUserInfo();
      setState(() {
        _currentUserId = userInfo?['id'];
      });
    // ignore: empty_catches
    } catch (e) {
  
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: themeProvider.primaryColor,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Container(
              color: themeProvider.primaryColor,
              padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Liste des amis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _friends.isEmpty
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
