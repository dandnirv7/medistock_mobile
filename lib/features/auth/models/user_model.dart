class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.role = 'ADMIN',
  });

  final String id;
  final String name;
  final String username;
  final String? email;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: json['email'] as String?,
      role: (json['role'] ?? 'ADMIN').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'role': role,
      };
}

class LoginResponse {
  LoginResponse({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final source = data ?? json;
    return LoginResponse(
      token: (source['accessToken'] ?? source['token'] ?? '').toString(),
      user: UserModel.fromJson(
        (source['user'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
