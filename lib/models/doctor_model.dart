// models/doctor_model.dart

class DoctorModel {
  final int id;
  final String name;
  final String email;

  final HospitalModel? hospital;
  final SpecializationModel? specialization;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    this.hospital,
    this.specialization,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      hospital: json['hospital'] != null
          ? HospitalModel.fromJson(json['hospital'])
          : null,
      specialization: json['specialization'] != null
          ? SpecializationModel.fromJson(json['specialization'])
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
      address: json['address'],
      phone: json['phone'],
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
