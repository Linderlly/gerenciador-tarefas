class UserModel {
  String id;
  String name;
  String role;
  int points;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role, 'points': points};
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'],
      role: map['role'],
      points: map['points'],
    );
  }
}
