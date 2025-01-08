import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamup/components/AllUsersTab.dart';
import 'package:teamup/components/FriendRequestsTab.dart';
import 'package:teamup/components/theme_provider.dart';
import 'package:teamup/services/friend_service.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:teamup/pages/user_profile.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FriendsTabPage extends StatefulWidget {
  const FriendsTabPage({super.key});

  @override
  _FriendsTabPageState createState() => _FriendsTabPageState();
}

class _FriendsTabPageState extends State<FriendsTabPage>
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
  bool _isLoadingUsers = true;
  bool _isLoadingRequests = true;

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
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _channel.sink.close();
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
      // Handle error
    }
  }

  Future<void> _fetchAllUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
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
        _isLoadingUsers = false;
      });
      _fetchFriendRequests();
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      // Handle error
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
      // Handle error
    }
  }

  Future<void> _fetchFriendRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });
    try {
      final requests = await _friendService.getFriendRequests();
      setState(() {
        _friendRequests = requests
            .where((request) => request['receiver_id'] == _currentUserId)
            .toList();
        _hasNewFriendRequests = _friendRequests.isNotEmpty;
        for (var request in requests) {
          if (request['receiver_id'] == _currentUserId) {
            _friendRequestStatus[request['sender_id']] = request['status'];
          }
        }
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRequests = false;
      });
      // Handle error
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team - relations',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _isLoadingRequests
                    ? const Center(child: CircularProgressIndicator())
                    : _friendRequests.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_disabled,
                          size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucune demande d\'ami',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Vous n\'avez aucune demande d\'ami pour le moment.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : FriendRequestsTab(
                  friendRequests: _friendRequests,
                  onAccept: _acceptFriendRequest,
                  onDecline: _declineFriendRequest,
                ),
                _isLoadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredUsers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off,
                          size: 100, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucun utilisateur trouvé',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Aucun utilisateur ne correspond à votre recherche.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : AllUsersTab(
                  users: _filteredUsers,
                  friends: _friends,
                  friendRequestStatus: _friendRequestStatus,
                  onSendRequest: _sendFriendRequest,
                  onUserTap: _navigateToUserProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}