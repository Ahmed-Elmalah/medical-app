// 📁 lib/models/booking_model.dart
// (النسخة اللي بتصلح التوقيت)

import 'doctor_model.dart';
import 'user_model.dart';
import 'hospital_model.dart';
import 'doctor_schedule_model.dart';

class BookingModel {
  final int id;
  final DateTime date; // (ده الـ DateTime الصح)
  final String documentId;
  final String state; 
  final DoctorModel? doctor;
  final UserModel? user;
  final HospitalModel? hospital;
  final DoctorScheduleModel? doctorSchedule; 

  const BookingModel({
    required this.id,
    required this.documentId,
    required this.date,
    required this.state,
    this.doctor,
    this.user,
    this.hospital,
    this.doctorSchedule,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // (ده بيقرأ "flat" زي ما اتفقنا)
    
    return BookingModel(
      id: json['id'] ?? 0,
      documentId: json['documentId'] ?? '',
      
      // --- (🔥 التعديل هنا) ---
      date: json['date'] != null
          ? DateTime.parse(json['date']).toLocal() // (بنحول من UTC لتوقيتك المحلي)
          : DateTime.now(),
      // -------------------------
          
      state: json['state'] ?? 'Confirmed',

      doctor: json['doctor'] != null
          ? DoctorModel.fromJson(json['doctor'])
          : null,

      user: json['user'] != null 
          ? UserModel.fromJson(json['user']) 
          : null,
          
      hospital: json['hospital'] != null
          ? HospitalModel.fromJson(json['hospital'])
          : null,
          
      doctorSchedule: json['doctor_schedule'] != null
          ? DoctorScheduleModel.fromJson(json['doctor_schedule']) 
          : null,
    );
  }
}