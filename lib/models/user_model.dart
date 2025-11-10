// 📁 lib/models/user_model.dart
// (النسخة الصحيحة اللي بتقرأ الداتا الـ "flat")

class UserModel {
  final int id;
  final String username;
  final String email;
  final String roleName;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.roleName,
  });

  // ✅ الدالة دي بتطابق الـ API بتاعك (من غير 'attributes')
  factory UserModel.fromJson(Map<String, dynamic> json) {
    
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // (دي بتفضل زي ما هي لإن الـ role لسه object)
      roleName: (json['role'] as Map<String, dynamic>?)?['name'] ?? 'Authenticated',
    );
  }
}