// ------------------------------------------------------
// Hospital Model
// ده الموديل اللي بيمسك بيانات المستشفى من الـ API
// ------------------------------------------------------

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

  // تحويل JSON → HospitalModel
  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      phone: json["phone"],
    );
  }
}
