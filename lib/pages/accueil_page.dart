import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamup/pages/MatchDetailsPage.dart';
import 'package:teamup/services/Match_service.dart';
import 'package:teamup/services/auth.service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../components/theme_provider.dart';
import '../components/MatchCard.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage>
    with SingleTickerProviderStateMixin {
  final MatchService _matchService = MatchService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _matches = [];
  final Set<String> _joinedMatches = {};
  bool _isLoading = true;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedMatch;
  BitmapDescriptor? _customMarkerIcon;
  String? _userId;
  Timer? _timer;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _fetchUserAndMatches();
    _loadCustomMarker();
    _startAutoRefresh();

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchMatches();
    });
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
    setState(() {
      _isLoading = true;
    });

    try {
      final matches = await _matchService.getMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
        _setMarkers();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors de la récupération des matchs: $e');
    }
  }

  DateTime? _parseDateTime(String dateTime) {
    try {
      return DateTime.parse(dateTime);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(String date) {
    final parsedDate = _parseDateTime(date);
    if (parsedDate != null) {
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    }
    return date;
  }

  String _formatTime(String time) {
    final parsedTime = _parseDateTime(time);
    if (parsedTime != null) {
      return DateFormat('HH:mm').format(parsedTime);
    }
    return time;
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
      if (match['status'] == 'completed') continue;
      final String matchId = match['id']?.toString() ?? '';
      final String address = match['address'] ?? 'No Address';

      try {
        final coordinates = await _matchService.getCoordinates(address);
        final double latitude = coordinates['latitude'];
        final double longitude = coordinates['longitude'];
        final marker = Marker(
          markerId: MarkerId(matchId),
          position: LatLng(latitude, longitude),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            if (_isOffline) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Vous ne pouvez pas afficher les détails du marqueur car vous n\'êtes pas connecté à Internet.',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            } else {
              setState(() {
                _selectedMatch = match;
              });
            }
          },
        );

        _markers.add(marker);
      } catch (e) {
        print(
            'Erreur lors de la récupération des coordonnées pour l\'adresse $address: $e');
      }
    }
    setState(() {});
  }

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _joinMatch(String matchId) async {
    if (await _checkConnectivity()) {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Vous avez rejoint le match avec succès !',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Erreur lors de la jointure du match',
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vous êtes hors ligne. Veuillez vous connecter à Internet pour rejoindre un match.',
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

  void _leaveMatch(String matchId) async {
    if (await _checkConnectivity()) {
      try {
        await _matchService.leaveMatch(matchId);
        final userInfo = await _authService.getUserInfo();
        if (userInfo != null && userInfo.containsKey('id')) {
          setState(() {
            _joinedMatches.remove(matchId);
            _selectedMatch = null;
          });
          _saveJoinedMatches(userInfo['id']);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Vous avez quitté le match avec succès',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Erreur lors de la tentative de quitter le match',
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Vous êtes hors ligne. Veuillez vous connecter à Internet pour quitter un match.',
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
    if (_mapController != null) {
      if (themeProvider.isDarkTheme) {
        final String style =
            await rootBundle.loadString('assets/map_style_dark.json');
        _mapController!.setMapStyle(style);
      } else {
        _mapController!.setMapStyle(null);
      }
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
        centerTitle: true,
        backgroundColor: themeProvider.primaryColor,
        title: Image.asset(
          'assets/logos/grey_logo.png',
          height: 80,
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Accueil'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Paramètres'),
            ),
          ],
        ),
      ),
      body: _isLoading
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
                                    _selectedMatch!['description'] ?? '', 24),
                                matchDate: _selectedMatch!['date'] ?? '',
                                matchTime: _selectedMatch!['time'] ?? '',
                                endTime: _selectedMatch!['end_time'] ?? '',
                                address: _truncateText(
                                    _selectedMatch!['address'] ?? '', 24),
                                status: _selectedMatch!['status'] ?? '',
                                numberOfPlayers:
                                    _selectedMatch!['number_of_players'] ?? 0,
                                isOrganizer:
                                    _selectedMatch!['organizer_id'] == _userId,
                                onJoin: () {
                                  print('Join button pressed');
                                  print('Match ID: ${_selectedMatch!['id']}');
                                  print('User ID: $_userId');
                                  _joinMatch(_selectedMatch!['id']);
                                },
                                onLeave: () {
                                  print('Leave button pressed');
                                  print('Match ID: ${_selectedMatch!['id']}');
                                  print('User ID: $_userId');
                                  _leaveMatch(_selectedMatch!['id']);
                                },
                                joinedMatches: _joinedMatches,
                                matchId: _selectedMatch!['id'].toString(),
                                userId: _userId ?? '',
                                showJoinLeaveButtons:
                                    _selectedMatch!['organizer_id'] != _userId,
                                playerIds:
                                    _selectedMatch!['player_ids']?.toSet() ??
                                        {}, // Ajoutez cette ligne
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
                                    child: Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
