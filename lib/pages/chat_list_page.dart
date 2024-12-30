import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/friend.service.dart';
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

  @override
  void initState() {
    super.initState();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          title: const Text('Liste des amis',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: themeProvider.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: themeProvider.iconColor),
              onPressed: () {
                // Action de recherche
              },
            ),
          ],
        ),
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(friendName: friend['username']),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
