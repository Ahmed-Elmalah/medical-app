// 📁 lib/models/user_model.dart
// (النسخة الصحيحة "flat")

class UserModel {
  final int id;
  final String username;
  final String email;
  final String roleName;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.roleName,
  });

  // ✅ الدالة دي بتقرأ الـ JSON الـ "flat"
  factory UserModel.fromJson(Map<String, dynamic> json) {
    
    final roleData = json['role'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roleName: roleData?['name'] ?? 'Authenticated',
    );
  }
}