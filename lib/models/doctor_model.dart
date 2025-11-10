// 📁 lib/models/doctor_model.dart
// (النسخة اللي فيها workingDays)

// (امسح أي 'import' لـ hospital أو specialization من هنا)

class DoctorModel {
  final int id;
  final String name;
  final String email;
  final HospitalModel? hospital;
  final SpecializationModel? specialization;
  final Map<String, dynamic>? workingHours;
  final List<String>? workingDays; // (1) 🔥 تم تصليحها
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
      
      // (2) 🔥 تم تصليحها من "workingKids"
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

// --- (الكلاسات دي خليها في نفس الملف) ---

class HospitalModel {
  final int id;
  final String name;
  final String address;
  final String phone;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class SpecializationModel {
  final int id;
  final String name;

  const SpecializationModel({required this.id, required this.name});

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: json['id'] ?? 0, 
      name: json['name'] ?? ''
    );
  }
}