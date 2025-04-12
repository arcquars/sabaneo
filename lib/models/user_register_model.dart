class UserRegister {
  final int? id;
  final String name;
  final String username;
  final String email;
  final String role;

  final String phone;
  final String store;

  UserRegister({
    this.id, 
    required this.name, 
    required this.username, 
    required this.email, 
    required this.role,
    required this.phone,
    required this.store
    });

  factory UserRegister.fromJson(Map<String, dynamic> json) {
    return UserRegister(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      store: json['store']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username':username,
      'email': email,
      'role': role,
      'phone': phone,
      'store': store
    };
  }
}