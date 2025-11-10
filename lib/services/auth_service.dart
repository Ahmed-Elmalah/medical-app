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
        headers: {
          'Content-Type': 'application/json',
        },
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
        return {'success': false, 'message': error['message'] ?? "Registration failed"};
      }
    } catch (e) {
      // فشل بسبب مشكلة في النت أو السيرفر
      return {'success': false, 'message': 'Check your connection: $e'};
    }
  }

  // 📁 (داخل كلاس AuthService في lib/services/auth_service.dart)

 // 📁 (داخل كلاس AuthService في lib/services/auth_service.dart)

  // ✅ دالة اللوجين الجديدة (المعدلة)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final String loginUrl = "$_baseUrl/auth/local";
    final String meUrl = "$_baseUrl/users/me?populate=role"; // (1) 🔥 اللينك الجديد

    try {
      // ------------------------------------
      // (2) الخطوة الأولى: محاولة اللوجين
      // ------------------------------------
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'identifier': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        // فشل اللوجين
        final error = json.decode(response.body)['error'];
        return {'success': false, 'message': error['message'] ?? "Login failed"};
      }

      final loginData = json.decode(response.body);
      final String jwt = loginData['jwt']; // (3) خدنا التوكن

      // ------------------------------------
      // (4) الخطوة الثانية: نجيب بيانات اليوزر الكاملة بالـ Role
      // ------------------------------------
      final meResponse = await http.get(
        Uri.parse(meUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt', // (5) استخدمنا التوكن
        },
      );

      if (meResponse.statusCode != 200) {
        // نجح اللوجين، بس فشلنا نجيب بياناته (نادر)
        return {'success': false, 'message': "Login successful, but failed to fetch user data."};
      }

      // (6) هنا معانا بيانات اليوزر كاملة (بالـ Role)
      final userData = json.decode(meResponse.body);
      
      // (7) بنحول الـ JSON لموديل اليوزر
      final user = UserModel.fromJson(userData); 

      // (8) بنرجع بيانات اليوزر والـ Token
      return {'success': true, 'user': user, 'jwt': jwt};

    } catch (e) {
      return {'success': false, 'message': 'Check your connection: $e'};
    }
  }
}

