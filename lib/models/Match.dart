class Match {
  final String address;
  final String createdAt;
  final String description;
  final String id;
  final String matchDate;
  final String matchTime;
  final int numberOfPlayers;
  final String organizerUsername;
  final String organizerProfilePhoto;
  final String status;
  final String updatedAt;

  Match({
    required this.address,
    required this.createdAt,
    required this.description,
    required this.id,
    required this.matchDate,
    required this.matchTime,
    required this.numberOfPlayers,
    required this.organizerUsername,
    required this.organizerProfilePhoto,
    required this.status,
    required this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      address: json['address'],
      createdAt: json['created_at'],
      description: json['description'],
      id: json['id'],
      matchDate: json['match_date'],
      matchTime: json['match_time'],
      numberOfPlayers: json['number_of_players'],
      organizerUsername: json['organizer']['username'],
      organizerProfilePhoto: json['organizer']['profile_photo'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }
}