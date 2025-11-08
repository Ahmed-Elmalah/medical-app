// 📁 lib/models/hospital_model.dart

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

  // ✅ من JSON إلى موديل
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // ✅ من موديل إلى JSON (عشان تشتغل مع toJson في DoctorModel)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
    };
  }
}
