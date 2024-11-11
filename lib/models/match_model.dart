class Match {
  final String id;
  final String organizer;
  final String address;
  final String status;
  final DateTime matchDate;

  Match({
    required this.id,
    required this.organizer,
    required this.address,
    required this.status,
    required this.matchDate,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      organizer: json['organizer']['name'], // On suppose que l'API renvoie l'organisateur dans un objet
      address: json['address'],
      status: json['status'],
      matchDate: DateTime.parse(json['date']),
    );
  }
}
