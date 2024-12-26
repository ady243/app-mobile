import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/services/auth.service.dart';
import '../components/theme_provider.dart';
import '../services/MatchService.dart';
import 'MatchDetailsPage.dart';
import '../components/MatchCard.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _matches = [];
  final Set<String> _joinedMatches = {};
  bool _isLoading = true;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedMatch;
  BitmapDescriptor? _customMarkerIcon;
  String? _userId;
  Timer? _timer;
  Timer? _socketTimer;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchUserAndMatches();
    _loadCustomMarker();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _matchService.closeWebSocket();
    _timer?.cancel();
    _socketTimer?.cancel();
    super.dispose();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: selectNotification);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // handle your actions
  }

  Future<void> selectNotification(
      NotificationResponse notificationResponse) async {
    // handle your actions
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _fetchMatches();
    });
  }

  void _scheduleSocketConnection(DateTime matchDateTime) {
    final now = DateTime.now();
    if (matchDateTime.isAfter(now)) {
      final durationUntilMatch = matchDateTime.difference(now);
      _socketTimer = Timer(durationUntilMatch, () {
        _connectWebSocket();
      });
    } else {
      _connectWebSocket();
    }
  }

  void _connectWebSocket() {
    _matchService.connectWebSocket((data) {
      final matchId = data['match_id'];
      final status = data['status'];

      setState(() {
        final matchIndex =
            _matches.indexWhere((match) => match['id'] == matchId);
        if (matchIndex != -1) {
          _matches[matchIndex]['status'] = status;
          if (_joinedMatches.contains(matchId)) {
            _showNotification(matchId, status);
          }
        }
      });
    });
  }

  void _showNotification(String matchId, String status) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    String title = 'Mise à jour du match';
    String body = '';

    switch (status) {
      case 'upcoming':
        body = 'Le match $matchId est à venir.';
        break;
      case 'ongoing':
        body = 'Le match $matchId a commencé.';
        break;
      case 'completed':
        body = 'Le match $matchId est terminé.';
        break;
      case 'expired':
        body = 'Le match $matchId a expiré.';
        break;
      default:
        body = 'Statut inconnu pour le match $matchId.';
    }

    await _flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  void _fetchUserAndMatches() async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo != null && userInfo.containsKey('id')) {
      final userId = userInfo['id'];
      setState(() {
        _userId = userId;
      });
      _loadJoinedMatches(userId);
      _fetchMatches();
    }
  }

  void _loadJoinedMatches(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final joinedMatches = prefs.getStringList('joinedMatches_$userId') ?? [];
    setState(() {
      _joinedMatches.addAll(joinedMatches);
    });
  }

  void _saveJoinedMatches(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('joinedMatches_$userId', _joinedMatches.toList());
  }

  void _fetchMatches() async {
    try {
      final matches = await _matchService.getMatches();
      print('Matches fetched: $matches');
      setState(() {
        _matches = matches;
        _isLoading = false;
        _setMarkers();
      });
      _updateMatchLists();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors de la récupération des matchs: $e');
    }
  }

  void _updateMatchLists() {
    final now = DateTime.now();
    for (var match in _matches) {
      final matchDateTime = _parseDateTime(match['date'], match['time']);
      final endDateTime = _parseDateTime(match['date'], match['end_time']);
      if (matchDateTime != null && endDateTime != null) {
        print('Match DateTime: $matchDateTime, Now: $now');
        if (now.isAfter(endDateTime)) {
          match['status'] = 'completed';
        } else if (now.isAfter(matchDateTime) && now.isBefore(endDateTime)) {
          match['status'] = 'ongoing';
        } else {
          match['status'] = 'upcoming';
          _scheduleSocketConnection(matchDateTime);
        }
      }
    }
    setState(() {});
  }

  DateTime? _parseDateTime(String date, String time) {
    try {
      final dateTimeString = '${date.split('T')[0]}T${time.split('T')[1]}';
      print('Parsing DateTime: $dateTimeString');
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('Erreur lors de la conversion de la date et de l\'heure: $e');
      return null;
    }
  }

  Future<BitmapDescriptor> _resizeImage(
      String assetPath, int width, int height) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? resizedData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    // ignore: deprecated_member_use
    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }

  void _loadCustomMarker() async {
    final BitmapDescriptor markerIcon =
        await _resizeImage('assets/logos/grey_logo.png', 200, 200);
    setState(() {
      _customMarkerIcon = markerIcon;
    });
  }

  void _setMarkers() async {
    _markers.clear();
    for (var match in _matches) {
      final String description = match['description'] ?? 'No Description';
      final String matchId = match['id']?.toString() ?? '';
      final String address = match['address'] ?? 'No Address';

      try {
        final coordinates = await _matchService.getCoordinates(address);
        final double latitude = coordinates['latitude'];
        final double longitude = coordinates['longitude'];

        print(
            'Match: $description, Latitude: $latitude, Longitude: $longitude');

        final marker = Marker(
          markerId: MarkerId(matchId),
          position: LatLng(latitude, longitude),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            setState(() {
              _selectedMatch = match;
            });
          },
        );

        _markers.add(marker);
      } catch (e) {
        print('Erreur lors de la récupération des coordonnées: $e');
      }
    }
    setState(() {});
  }

  void _joinMatch(String matchId) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null || !userInfo.containsKey('id')) {
        throw Exception('Impossible de récupérer l\'ID utilisateur');
      }
      final playerId = userInfo['id'];

      await _matchService.joinMatch(matchId, playerId);
      setState(() {
        _joinedMatches.add(matchId);
        _selectedMatch = null;
      });
      _saveJoinedMatches(playerId);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez rejoint le match !')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Erreur lors de la tentative de rejoindre le match.')),
      );
    }
  }

  void _navigateToMatchDetails(String matchId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailsPage(matchId: matchId),
      ),
    );
  }

  Future<void> _setMapStyle() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (themeProvider.isDarkTheme) {
      final String style =
          await rootBundle.loadString('assets/map_style_dark.json');

      // ignore: deprecated_member_use
      _mapController.setMapStyle(style);
    } else {
      // ignore: deprecated_member_use
      _mapController.setMapStyle(null);
    }
  }

  String _truncateText(String text, int length) {
    return text.length > length ? '${text.substring(0, length)}...' : text;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Matchs',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            color: themeProvider.primaryColor,
            padding: const EdgeInsets.only(top: 20.0),
            width: double.infinity,
            height: 90,
            child: Center(
              child: Image.asset(
                'assets/logos/grey_logo.png',
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _matches.isEmpty
                    ? _buildEmptyState()
                    : Stack(
                        children: [
                          GoogleMap(
                            onMapCreated: (controller) {
                              _mapController = controller;
                              _setMapStyle();
                            },
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(48.8566, 2.3522),
                              zoom: 6,
                            ),
                            markers: _markers,
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                          ),
                          if (_selectedMatch != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _navigateToMatchDetails(
                                    _selectedMatch!['id'].toString()),
                                child: Stack(
                                  children: [
                                    MatchCard(
                                      description: _truncateText(
                                          _selectedMatch!['description'] ?? '',
                                          24),
                                      matchDate: _selectedMatch!['date'] ?? '',
                                      matchTime: _selectedMatch!['time'] ?? '',
                                      endTime:
                                          _selectedMatch!['end_time'] ?? '',
                                      address: _truncateText(
                                          _selectedMatch!['address'] ?? '', 24),
                                      status: _selectedMatch!['status'] ?? '',
                                      numberOfPlayers: _selectedMatch![
                                              'number_of_players'] ??
                                          0,
                                      isJoined: _joinedMatches
                                          .contains(_selectedMatch!['id']),
                                      isOrganizer:
                                          _selectedMatch!['organizer_id'] ==
                                              _userId,
                                      onJoin: () =>
                                          _joinMatch(_selectedMatch!['id']),
                                      joinedMatches: _joinedMatches,
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedMatch = null;
                                          });
                                        },
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.blueGrey,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/image_empty.png',
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun match disponible pour le moment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Revenez plus tard ou créez un nouveau match !',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
