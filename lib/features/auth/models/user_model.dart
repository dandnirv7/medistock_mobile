enum UserRole { admin, staff }

extension UserRoleX on UserRole {
  String get apiValue => switch (this) {
        UserRole.admin => 'ADMIN',
        UserRole.staff => 'STAFF',
      };

  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.staff => 'Staff',
      };

  static UserRole fromApi(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'STAFF':
        return UserRole.staff;
      case 'ADMIN':
      default:
        return UserRole.admin;
    }
  }
}

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

  UserRole get userRole => UserRoleX.fromApi(role);
  bool get isAdmin => userRole == UserRole.admin;
  bool get isStaff => userRole == UserRole.staff;

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
