// 📁 lib/models/booking_model.dart
// (النسخة الصحيحة اللي بتقرأ الداتا الـ "flat")

import 'doctor_model.dart';
import 'user_model.dart';

class BookingModel {
  final int id;
  final DateTime date;
  final String documentId;
  final DoctorModel? doctor;
  final UserModel? user;

  const BookingModel({
    // (بقت const)
    required this.id,
    required this.documentId,
    required this.date,
    this.doctor,
    this.user,
  });

  // (1) 🔥 الدالة دي بتطابق الـ JSON الـ "flat"
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      documentId: json['documentId'] ?? "",
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),

      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'])
          : null,

      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
