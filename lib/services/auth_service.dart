// 📁 lib/services/auth_service.dart
// (النسخة المبسطة بعد تعديل الـ Default Role في Strapi)

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = "http://localhost:1337/api";

  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
  }) async {
    final String registerUrl = "$_baseUrl/auth/local/register";

    try {
      // ✅ خطوة واحدة بس: تسجيل عادي
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': name,
          'email': email,
          'password': password,
          // (مبقناش محتاجين نبعت أي حاجة عن الـ Role)
        }),
      );

      if (response.statusCode == 200) {
        // نجح التسجيل
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        // فشل التسجيل (مثلاً: الإيميل موجود قبل كده)
        final error = json.decode(response.body)['error'];
        return {
          'success': false,
          'message': error['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      // فشل بسبب مشكلة في النت أو السيرفر
      return {'success': false, 'message': 'Check your connection: $e'};
    }
  }

  // دالة اللوجين الموحدة
  Future<Map<String, dynamic>> unifiedLogin({
    required String email,
    required String password,
  }) async {
    final String loginUrl = "$_baseUrl/auth/local";
    final String meUrl = "$_baseUrl/users/me?populate=role";

    try {
      // الخطوة 1: محاولة اللوجين
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body)['error'];
        return {
          'success': false,
          'message': error['message'] ?? "Login failed",
        };
      }

      final loginData = json.decode(response.body);
      final String jwt = loginData['jwt'];

      // الخطوة 2: نجيب بيانات اليوزر الكاملة
      final meResponse = await http.get(
        Uri.parse(meUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (meResponse.statusCode != 200) {
        return {
          'success': false,
          'message': "Login successful, but failed to fetch user data.",
        };
      }

      final userData = json.decode(meResponse.body);
      final user = UserModel.fromJson(userData);
      final role = user.roleName.toLowerCase();

      return {'success': true, 'user': user, 'role': role, 'jwt': jwt};
    } catch (e) {
      return {'success': false, 'message': 'Check your connection: $e'};
    }
  }
}
