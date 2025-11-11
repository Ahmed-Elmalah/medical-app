// 📁 lib/models/doctor_model.dart
// (النسخة الصحيحة "flat")

import 'hospital_model.dart';
import 'specialization_model.dart';

class DoctorModel {
  final int id;
  final String name;
  final String email;
  final HospitalModel? hospital;
  final SpecializationModel? specialization;
  final Map<String, dynamic>? workingHours;
  final List<String>? workingDays;
  final String? imageUrl;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.hospital,
    this.specialization,
    this.workingHours,
    this.workingDays,
    this.imageUrl,
  });

  // ✅ الدالة دي بتقرأ الـ JSON الـ "flat"
  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    String? finalImgUrl;
    if (json['img'] != null && json['img']['url'] != null) {
      finalImgUrl = json['img']['url'];
    }

    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? '',
      
      workingHours: json['workingHours'] != null
          ? Map<String, dynamic>.from(json['workingHours'])
          : null,
      
      workingDays: json['workingDays'] != null
          ? List<String>.from(json['workingDays']) 
          : [],

      hospital: json['hospital'] != null
          ? HospitalModel.fromJson(json['hospital'])
          : null,
      
      specialization: json['specialization'] != null
          ? SpecializationModel.fromJson(json['specialization'])
          : null,
          
      imageUrl: finalImgUrl,
    );
  }
}

