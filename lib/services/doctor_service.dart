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
}
