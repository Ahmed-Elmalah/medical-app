import 'package:flutter/material.dart';

class FiltersSection extends StatelessWidget {
  final String selectedHospital;
  final String selectedSpecialization;
  final String selectedDoctor;
  final List<String> hospitals;
  final List<String> specializations;
  final List<String> doctorNames;
  final ValueChanged<String?> onHospitalChanged;
  final ValueChanged<String?> onSpecializationChanged;
  final ValueChanged<String?> onDoctorChanged;
  final VoidCallback onSearchPressed;

  const FiltersSection({
    Key? key,
    required this.selectedHospital,
    required this.selectedSpecialization,
    required this.selectedDoctor,
    required this.hospitals,
    required this.specializations,
    required this.doctorNames,
    required this.onHospitalChanged,
    required this.onSpecializationChanged,
    required this.onDoctorChanged,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Hospital",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          value: selectedHospital,
          items: hospitals
              .map((h) => DropdownMenuItem(value: h, child: Text(h)))
              .toList(),
          onChanged: onHospitalChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Specialization",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          value: selectedSpecialization,
          items: specializations
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: onSpecializationChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Doctor (optional)",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          value: selectedDoctor,
          items: doctorNames
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: onDoctorChanged,
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: onSearchPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: const Size(180, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text(
              "Show Results",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
