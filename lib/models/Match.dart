class User {
  final String id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? 'Organisateur inconnu',
    );
  }
}

class Match {
  final String address;
  final String createdAt;
  final String description;
  final String id;
  final String matchDate;
  final String matchTime;
  final int numberOfPlayers;
  final User organizer;
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
    required this.organizer,
    required this.status,
    required this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      address: json['address'] ?? '',
      createdAt: json['created_at'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? '',
      matchDate: json['date'] ?? '',
      matchTime: json['time'] ?? '',
      numberOfPlayers: json['number_of_players'] ?? 0,
      organizer: User.fromJson(json['organizer'] ?? {}),
      status: json['status'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}