// 📁 lib/services/booking_service.dart
// (النسخة النهائية اللي فيها cancel صح)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/booking_model.dart';

class BookingService {
  static const String _baseUrl = "http://localhost:1337/api";

  // (دالة الحجز بتاعتك سليمة 100%)
  Future<bool> createBooking({
    required int doctorId,
    required int userId,
    required String selectedDay,
    required String fromTime,
    required String token,
  }) async {
    final String url = "$_baseUrl/bookings";
    try {
      final DateTime bookingDate = _getNextDateTime(selectedDay, fromTime);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'data': {
            'date': bookingDate.toIso8601String(),
            'doctor': doctorId,
            'user': userId,
          },
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body);
        if (body['data'] != null) {
          return true;
        } else {
          print(
            "Booking failed: Strapi returned ${response.statusCode} but no data.",
          );
          return false;
        }
      } else {
        print("Failed to create booking (Status Code): ${response.statusCode}");
        print("Failed to create booking (Body): ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error creating booking: $e");
      return false;
    }
  }

  // (دالة الوقت سليمة 100%)
  DateTime _getNextDateTime(String dayName, String time) {
    final now = DateTime.now();
    DateTime parsedTime;
    final String timeToParse = time.toUpperCase();
    try {
      final DateFormat timeFormatAmPm = DateFormat("h:mm a");
      parsedTime = timeFormatAmPm.parse(timeToParse);
    } catch (e) {
      try {
        final DateFormat timeFormat24 = DateFormat("HH:mm");
        parsedTime = timeFormat24.parse(timeToParse);
      } catch (e2) {
        parsedTime = DateTime(now.year, now.month, now.day, 9, 0);
      }
    }
    final daysOfWeek = [
      "MONDAY",
      "TUESDAY",
      "WEDNESDAY",
      "THURSDAY",
      "FRIDAY",
      "SATURDAY",
      "SUNDAY",
    ];
    int selectedDayIndex = daysOfWeek.indexOf(dayName.toUpperCase());
    int currentDayIndex = now.weekday - 1;
    int daysToAdd = selectedDayIndex - currentDayIndex;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
    DateTime nextBookingDay = now.add(Duration(days: daysToAdd));
    return DateTime(
      nextBookingDay.year,
      nextBookingDay.month,
      nextBookingDay.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  // (دالة جلب الحجوزات سليمة 100%)
  Future<List<BookingModel>> getUserBookings({
    required int userId,
    required String token,
  }) async {
    final String url =
        "$_baseUrl/bookings?populate=*&filters[user][id][\$eq]=$userId";
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
        final List bookingsJson = body['data'];
        return bookingsJson
            .map((jsonItem) => BookingModel.fromJson(jsonItem))
            .toList();
      } else {
        print("Failed to load bookings: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error loading bookings: $e");
      return [];
    }
  }

  Future<bool> cancelBooking({
    required String documentId,
    required String token,
  }) async {
    final url = "$_baseUrl/bookings/$documentId";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      // ✅ Strapi v4 on DELETE returns:
      // 204 No Content  OR
      // 200 {}  OR
      // 200 { "data": null }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      print("Failed to cancel: ${response.statusCode}");
      print("Body: ${response.body}");
      return false;
    } catch (e) {
      print("Cancel error: $e");
      return false;
    }
  }
}
