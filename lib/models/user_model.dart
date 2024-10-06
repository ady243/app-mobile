class User {
  String id;
  String username;
  String email;
  String profilePhoto;
  String birthDate;
  String role;
  String favoriteSport;
  String location;
  String skillLevel;
  String bio;
  int pac;
  int sho;
  int pas;
  int dri;
  int def;
  int phy;
  int matchesPlayed;
  int matchesWon;
  int goalsScored;
  int behaviorScore;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePhoto,
    required this.birthDate,
    required this.role,
    required this.favoriteSport,
    required this.location,
    required this.skillLevel,
    required this.bio,
    required this.pac,
    required this.sho,
    required this.pas,
    required this.dri,
    required this.def,
    required this.phy,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.goalsScored,
    required this.behaviorScore,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profilePhoto: json['profile_photo'],
      birthDate: json['birth_date'] ?? '',
      role: json['role'],
      favoriteSport: json['favorite_sport'],
      location: json['location'],
      skillLevel: json['skill_level'],
      bio: json['bio'],
      pac: json['pac'],
      sho: json['sho'],
      pas: json['pas'],
      dri: json['dri'],
      def: json['def'],
      phy: json['phy'],
      matchesPlayed: json['matches_played'],
      matchesWon: json['matches_won'],
      goalsScored: json['goals_scored'],
      behaviorScore: json['behavior_score'],
    );
  }
}
