class User {
  final int id;
  final String username;
  final String firstname;
  final String lastname;
  final String email;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'role': role,
    };
  }

  String get fullName => '$firstname $lastname';
  bool get isAdmin => role == 'admin';
}
