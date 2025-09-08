class User {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}