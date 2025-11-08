// ------------------------------------------------------
// Hospital Service
// بيجيب المستشفيات من الـ API بدل الـ dummy data
// ------------------------------------------------------

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/hospital_model.dart';

class HospitalService {
  // ضيف لينك الـ API الحقيقي بتاع المستشفيات هنا
  static const String baseUrl =
      "http://localhost:1337/api/hospitals";

  // الدالة اللي بترجع List<HospitalModel>
  static Future<List<HospitalModel>> getHospitals() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode != 200) {
        throw Exception("Failed to load hospitals");
      }

      final decoded = json.decode(response.body);

      List data = decoded["data"];

      // نحول الـ JSON لموديل
      return data.map((h) => HospitalModel.fromJson(h)).toList();
    } catch (e) {
      print("ERROR LOADING HOSPITALS: $e");
      return [];
    }
  }
}
