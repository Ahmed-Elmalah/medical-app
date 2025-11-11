// 📁 lib/models/specialization_model.dart

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