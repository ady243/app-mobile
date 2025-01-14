import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/friend_service.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/pages/user_profile.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FriendsTabComponent extends StatefulWidget {
  const FriendsTabComponent({super.key});

  @override
  _FriendsTabComponentState createState() => _FriendsTabComponentState();
}

class _FriendsTabComponentState extends State<FriendsTabComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  List<dynamic> _friends = [];
  List<dynamic> _friendRequests = [];
  late WebSocketChannel _channel;
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();
  String? _currentUserId;
  final Map<String, String> _friendRequestStatus = {};
  bool _hasNewFriendRequests = false;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentUser();
    _searchController.addListener(_onSearchChanged);

    _channel =
        WebSocketChannel.connect(Uri.parse('wss://api-teamup.onrender.com/ws'));

    _channel.stream.listen((message) {
      // Handle WebSocket messages
      final notification = jsonDecode(message);
      if (notification['type'] == 'friend_request' ||
          notification['type'] == 'friend_request_accepted' ||
          notification['type'] == 'friend_request_declined') {
        _fetchFriends();
        _fetchFriendRequests();
        if (notification['type'] == 'friend_request') {
          setState(() {
            _hasNewFriendRequests = true;
          });
        }
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchFriendRequests();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _channel.sink.close();
    _timer?.cancel();
    _tabController
        .dispose(); // Ajoutez cette ligne pour nettoyer le TabController
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final userInfo = await _authService.getUserInfo();
      setState(() {
        _currentUserId = userInfo?['id'];
      });
      _fetchAllUsers();
      _fetchFriends();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllUsers() async {
    try {
      final users = await _authService.getAllUsers();
      setState(() {
        _allUsers =
            users.where((user) => user['id'] != _currentUserId).toList();
        _filteredUsers = _allUsers
            .where(
                (user) => !_friends.any((friend) => friend['id'] == user['id']))
            .toList();
        for (var user in _allUsers) {
          _friendRequestStatus[user['id']] = 'none';
        }
      });
      _fetchFriendRequests();
    } catch (e) {
      print('Failed to fetch users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFriends() async {
    try {
      final friends = await _friendService.getFriends();
      setState(() {
        _friends = friends;
        _filteredUsers = _allUsers
            .where(
                (user) => !_friends.any((friend) => friend['id'] == user['id']))
            .toList();
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
    }
  }

  Future<void> _fetchFriendRequests() async {
    try {
      final requests = await _friendService.getFriendRequests();
      setState(() {
        _friendRequests = requests
            .where((request) => request['receiver_id'] == _currentUserId)
            .toList();
        _hasNewFriendRequests = _friendRequests.isNotEmpty;
        for (var request in requests) {
          if (request['sender_id'] == _currentUserId) {
            _friendRequestStatus[request['receiver_id']] = request['status'];
          } else if (request['receiver_id'] == _currentUserId) {
            _friendRequestStatus[request['sender_id']] = request['status'];
          }
        }
      });
    } catch (e) {
      print('Failed to fetch friend requests: $e');
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user['username']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
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

  Future<void> _acceptFriendRequest(String senderId) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        throw Exception('User not logged in');
      }

      final receiverId = userInfo['id'];
      await _friendService.acceptFriendRequest(senderId, receiverId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Demande d\'ami acceptée avec succès',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _friendRequests
            .removeWhere((request) => request['sender_id'] == senderId);
        _friendRequestStatus[senderId] = 'accepted';
      });
      _fetchFriends();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de l\'acceptation de la demande d\'ami',
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

  Future<void> _declineFriendRequest(String senderId) async {
    try {
      await _friendService.declineFriendRequest(senderId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Demande d\'ami refusée avec succès',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _friendRequests
            .removeWhere((request) => request['sender_id'] == senderId);
        _friendRequestStatus.remove(senderId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors du refus de la demande d\'ami',
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

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      await _friendService.sendFriendRequest(receiverId);
      setState(() {
        _friendRequestStatus[receiverId] = 'pending';
        _filteredUsers.removeWhere((user) => user['id'] == receiverId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Demande d\'ami envoyée avec succès',
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
      if (e.toString().contains('Friend request already exists')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'La demande d\'ami existe déjà',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Erreur lors de l\'envoi de la demande d\'ami',
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
      print('Failed to send friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Container(
          color: themeProvider.isDarkTheme ? Colors.black : Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Stack(
                  children: [
                    const Tab(text: 'Demandes'),
                    if (_hasNewFriendRequests)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Tab(text: 'Tous les utilisateurs'),
            ],
            indicatorColor: Colors.green,
            labelColor: const Color(0xFF01BF6B),
            unselectedLabelColor: Colors.green,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _friendRequestsTab(),
                    _allUsersTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _friendRequestsTab() {
    return ListView.builder(
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];
        return ListTile(
          leading: CircleAvatar(
            child: request['sender']['profile_picture'] != null &&
                    request['sender']['profile_picture'].isNotEmpty
                ? Image.network(request['sender']['profile_picture'])
                : const Icon(Icons.person),
          ),
          title: Text(request['sender']['username']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _acceptFriendRequest(request['sender_id']),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _declineFriendRequest(request['sender_id']),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _allUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher des utilisateurs',
              labelStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              final isFriend =
                  _friends.any((friend) => friend['id'] == user['id']);
              final requestStatus = _friendRequestStatus[user['id']];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user['profile_picture'] != null &&
                          user['profile_picture'].isNotEmpty
                      ? NetworkImage(user['profile_picture'])
                      : null,
                  child: user['profile_picture'] == null ||
                          user['profile_picture'].isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user['username']),
                trailing: isFriend
                    ? const Icon(Icons.check, color: Colors.green)
                    : requestStatus == 'pending'
                        ? const Icon(Icons.hourglass_empty,
                            color: Colors.orange)
                        : IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () => _sendFriendRequest(user['id']),
                          ),
                onTap: () => _navigateToUserProfile(user['id']),
              );
            },
          ),
        ),
      ],
    );
  }
}
