// services/doctor_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/doctor_model.dart';

class DoctorService {
  static const String baseUrl = "http://localhost:1337/api/doctors?populate=*";

  static Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode != 200) {
        throw Exception("Failed to load doctors");
      }

      final decoded = json.decode(response.body);
      final List doctorsJson = decoded["data"];

      return doctorsJson
          .map((jsonItem) => DoctorModel.fromJson(jsonItem))
          .toList();
    } catch (e) {
      print("ERROR: $e");
      return [];
    }
  }

  // دالة تجيب الدكتور عن طريق email (بدل user id)
  static Future<DoctorModel> getDoctorByUserEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://localhost:1337/api/doctors?populate=*&filters[email][\$eq]=$email",
        ),
      );

      print("🔍 Fetching doctor for email: $email");
      print(
        "📡 URL: http://localhost:1337/api/doctors?populate=*&filters[email][\$eq]=$email",
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List doctorsJson = decoded["data"];

        print("📊 Response data: ${doctorsJson.length} doctors found");

        if (doctorsJson.isNotEmpty) {
          print("✅ Doctor found: ${doctorsJson.first['name']}");
          return DoctorModel.fromJson(doctorsJson.first);
        } else {
          print("❌ No doctor found for email: $email");
          throw Exception("Doctor not found for this email");
        }
      } else {
        print(
          "❌ API Error - Status: ${response.statusCode}, Body: ${response.body}",
        );
        throw Exception(
          "Failed to load doctor data - Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("🚨 ERROR getting doctor by email: $e");
      rethrow;
    }
  }
}
