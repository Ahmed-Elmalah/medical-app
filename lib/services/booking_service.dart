// 📁 lib/services/booking_service.dart
// (النسخة اللي بتبعت ID الميعاد و الـ state)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/booking_model.dart';

class BookingService {
  static const String _baseUrl = "http://localhost:1337/api";

  // --- (1) 🔥 التعديل هنا ---
  Future<bool> createBooking({
    required int doctorId,
    required int userId,
    required int hospitalId,
    required int scheduleId, // (ضفنا ده)
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
            'hospital': hospitalId,
            'doctor_schedule': scheduleId, // (بعتنا ID الميعاد)
            'state': 'Confirmed', // (بعتنا الحالة)
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

  // --- (1) 🔥 التعديل الصح هنا (بننفذ الخطة بتاعتك) ---
  Future<List<BookingModel>> getBookingsForDoctor({
    required int doctorId,
    required String token,
  }) async {
    // (1. هنجيب "كل" الحجوزات زي ما إنت قولت)
    final String url = "$_baseUrl/bookings?populate=*";

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

        // (2. هنحولهم كلهم لـ Models)
        final List<BookingModel> allBookings = bookingsJson
            .map((jsonItem) => BookingModel.fromJson(jsonItem))
            .toList();

        // (3. هنعمل "الفلترة" يدوي جوه فلاتر)
        final List<BookingModel> doctorBookings = allBookings.where((booking) {
          // (هنتأكد إن الحجز فيه دكتور، وإن الـ ID بتاعه هو اللي إحنا عايزينه)
          return booking.doctor != null && booking.doctor!.id == doctorId;
        }).toList();

        return doctorBookings; // (هنرجع القايمة المتفلترة)
      } else {
        print("Failed to load doctor bookings: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error loading doctor bookings: $e");
      return [];
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

  Future<bool> cancelBookingsBySchedule(int scheduleId, String token) async {
    try {
      // (أولاً: نجيب كل الحجوزات اللي على الميعاد ده)
      final String getUrl =
          "$_baseUrl/bookings?filters[doctor_schedule][id][\$eq]=$scheduleId";

      final getResponse = await http.get(
        Uri.parse(getUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (getResponse.statusCode != 200) {
        print("Failed to get bookings for schedule: ${getResponse.body}");
        return false; // (فشلنا نجيب الحجوزات)
      }

      final body = json.decode(getResponse.body);
      final List bookingsJson = body['data'];

      if (bookingsJson.isEmpty) {
        return true; // (مفيش حجوزات نلغيها، يبقى نجحنا)
      }

      // (ثانياً: نلف عليهم واحد واحد ونغير حالته)
      for (var booking in bookingsJson) {
        final int bookingId = booking['id'];
        final String updateUrl = "$_baseUrl/bookings/$bookingId";

        await http.put(
          Uri.parse(updateUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'data': {
              'state': 'Canceled_By_Doctor', // (بنغير الحالة)
            },
          }),
        );
        // (بنكمل اللفة حتى لو واحد فشل)
      }

      return true; // (خلصنا اللفة)
    } catch (e) {
      print("Error canceling bookings by schedule: $e");
      return false;
    }
  }
}
