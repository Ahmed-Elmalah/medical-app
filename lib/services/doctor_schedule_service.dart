// 📁 lib/services/doctor_schedule_service.dart
// (النسخة اللي بتصلح الفلتر)

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor_schedule_model.dart';
import 'booking_service.dart';

class DoctorScheduleService {
  static const String _baseUrl = "http://localhost:1337/api";
final BookingService _bookingService = BookingService(); // (2) 🔥 عملنا instance
  // --- (1) 🔥 التعديل الصح هنا ---
  Future<List<DoctorScheduleModel>> getSchedules(
      int doctorId, String token) async {
    // (شيلنا [id] من الفلتر)
    final String url =
        "$_baseUrl/doctor-schedules?populate=hospital&filters[doctor][\$eq]=$doctorId";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List data = body['data'];
        // (ده هيشتغل صح لما الداتا ترجع)
        return data.map((item) => DoctorScheduleModel.fromJson(item)).toList();
      } else {
        print("Failed to load schedules: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }

  // (دالة الإضافة زي ما هي سليمة)
  Future<bool> createSchedule(Map<String, dynamic> data, String token) async {
    final String url = "$_baseUrl/doctor-schedules";
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'data': data}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error creating schedule: $e");
      return false;
    }
  }

  // (دالة التعديل سليمة 100% زي ما هي)
  Future<bool> updateSchedule(
      String documentId, Map<String, dynamic> data, String token) async {
    final String url = "$_baseUrl/doctor-schedules/$documentId";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'data': data}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating schedule: $e");
      return false;
    }
  }

  // (دالة المسح سليمة 100% زي ما هي)
  Future<bool> deleteSchedule(
      String documentId, int scheduleId, String token) async {
        
    try {
      // (أولاً: ننفذ فكرتك ونلغي حجوزات المرضى)
      final bool cancelSuccess = 
        await _bookingService.cancelBookingsBySchedule(scheduleId, token);

      if (!cancelSuccess) {
        // (لو فشلنا نلغي الحجوزات، منمسحش الميعاد عشان نعرف المشكلة)
        print("Failed to cancel associated bookings. Aborting delete.");
        return false;
      }

      // (ثانياً: لو نجحنا، نمسح الميعاد نفسه)
      final String url = "$_baseUrl/doctor-schedules/$documentId";
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200 || response.statusCode == 204;

    } catch (e) {
      print("Error deleting schedule: $e");
      return false;
    }
  }

}