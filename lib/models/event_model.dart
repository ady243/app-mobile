class Event {
  final String id;
  final String matchId;
  final String analystId;
  final String playerId;
  final String eventType;
  final int minute;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.matchId,
    required this.analystId,
    required this.playerId,
    required this.eventType,
    required this.minute,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      matchId: json['match_id'],
      analystId: json['analyst_id'],
      playerId: json['player_id'],
      eventType: json['event_type'],
      minute: json['minute'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}