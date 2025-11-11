// 📁 lib/models/doctor_schedule_model.dart
// (النسخة الصحيحة "flat")

import 'hospital_model.dart';

class DoctorScheduleModel {
  final int id;
  final String documentId; 
  final String day;
  final String fromTime;
  final String toTime;
  final HospitalModel? hospital;

  DoctorScheduleModel({
    required this.id,
    required this.documentId,
    required this.day,
    required this.fromTime,
    required this.toTime,
    this.hospital,
  });

  // ✅ الدالة دي بتقرأ الـ JSON الـ "flat"
  factory DoctorScheduleModel.fromJson(Map<String, dynamic> json) {
    return DoctorScheduleModel(
      id: json['id'] ?? 0,
      documentId: json['documentId'] ?? '', 
      day: json['day'] ?? 'Error',
      fromTime: json['from_time'] ?? '00:00',
      toTime: json['to_time'] ?? '00:00',
      hospital: json['hospital'] != null
          ? HospitalModel.fromJson(json['hospital']) 
          : null,
    );
  }
}