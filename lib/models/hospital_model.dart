// 📁 lib/models/hospital_model.dart
// (النسخة الصحيحة "flat" + تصليح الـ Dropdown)

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

  // ✅ الدالة دي بتقرأ الـ JSON الـ "flat"
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  // (ده عشان يصلح إيرور الـ Dropdown في شاشة التعديل)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalModel &&
          runtimeType == other.runtimeType &&
          id == other.id; 

  @override
  int get hashCode => id.hashCode;
}