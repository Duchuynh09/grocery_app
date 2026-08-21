enum UserRole { admin, staff } // chủ tiệm / nhân viên

class AppUser {
  final String id;
  String username;
  String password; // demo đơn giản, thực tế nên hash khi nối CSDL thật
  String displayName;
  UserRole role;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;
}
