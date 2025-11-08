// models/doctor_model.dart

class DoctorModel {
  final int id;
  final String name;
  final String email;
  final HospitalModel? hospital;
  final SpecializationModel? specialization;
  final Map<String, dynamic>? workingHours;
  final List<String>? workingDays;
  final String? imageUrl;

  DoctorModel({
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
    return DoctorModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      hospital: json['hospital'] != null
          ? HospitalModel.fromJson(json['hospital'])
          : null,
      specialization: json['specialization'] != null
          ? SpecializationModel.fromJson(json['specialization'])
          : null,
      workingHours: json['workingHours'] != null
          ? Map<String, dynamic>.from(json['workingHours'])
          : null,
      workingDays: json['workingDays'] != null
          ? List<String>.from(json['workingDays'])
          : [],
      imageUrl: json['img'] != null
          ? json['img']['url'] // هنا بيجيب لينك الصورة من الـ API
          : null,
    );
  }
}

// MODEL FOR hospital
class HospitalModel {
  final int id;
  final String name;
  final String address;
  final String phone;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

// MODEL FOR specialization
class SpecializationModel {
  final int id;
  final String name;

  SpecializationModel({
    required this.id,
    required this.name,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
