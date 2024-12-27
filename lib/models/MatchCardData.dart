import 'package:flutter/material.dart';

class MatchCardData {
  final String description;
  final String matchDate;
  final String matchTime;
  final String endTime;
  final String address;
  final String status;
  final int numberOfPlayers;
  final bool isJoined;
  final bool isOrganizer;
  final VoidCallback? onTap;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  MatchCardData({
    required this.description,
    required this.matchDate,
    required this.matchTime,
    required this.endTime,
    required this.address,
    required this.status,
    required this.numberOfPlayers,
    required this.isJoined,
    required this.isOrganizer,
    this.onTap,
    required this.onJoin,
    required this.onLeave,
  });
}
