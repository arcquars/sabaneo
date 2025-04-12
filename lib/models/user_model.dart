class User {
  final String id;
  final String name;
  final String username;
  final String? email;
  final String role;

  User({required this.id, required this.name, required this.username, this.email, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username':username,
      'email': email,
      'role': role
    };
  }
}