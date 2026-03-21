class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String profilePicture;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.profilePicture,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'profilePicture': profilePicture,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
