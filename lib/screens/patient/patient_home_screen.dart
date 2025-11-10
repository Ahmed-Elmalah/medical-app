// 📁 lib/screens/patient/patient_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../widgets/filters_section.dart';
import '../../widgets/search_results_list.dart';
import '../../widgets/top_lists_section.dart';

import '../../services/doctor_service.dart';
import '../../services/hospital_service.dart';
import '../../models/doctor_model.dart' hide HospitalModel;
import '../../models/hospital_model.dart';
import '../../models/user_model.dart'; // (1) 🔥 استدعاء موديل اليوزر

class PatientHomeScreen extends StatefulWidget {
  final UserModel user; // (2) 🔥 ضفنا اليوزر
  final String jwt;    // (3) 🔥 ضفنا التوكن

  const PatientHomeScreen({
    Key? key, 
    required this.user, 
    required this.jwt // (4) 🔥 ضفناهم للـ constructor
  }) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // ... (كل المتغيرات زي ما هي)
  List<DoctorModel> allDoctors = [];
  List<HospitalModel> allHospitals = [];
  List<DoctorModel> filteredDoctors = [];
  List<String> filteredSpecializations = [];
  List<String> filteredDoctorsDropdown = [];
  String selectedHospital = "All Hospitals";
  String selectedSpecialization = "All Specializations";
  String selectedDoctor = "All Doctors";
  late ScrollController _doctorScrollController;
  late ScrollController _hospitalScrollController;
  Timer? _scrollTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _doctorScrollController = ScrollController();
    _hospitalScrollController = ScrollController();
    _loadHospitals();
    _loadDoctors();
    _startAutoScroll();
  }

  // ... (كل الدوال بتاعة الـ load والـ filter والـ scroll زي ما هي متغيرتش)
  void _loadHospitals() async {
    allHospitals = await HospitalService.getHospitals();
    setState(() {});
  }
  void _loadDoctors() async {
    allDoctors = await DoctorService.getDoctors();
    _prepareInitialDropdowns();
    setState(() {});
  }
  void _prepareInitialDropdowns() {
    filteredSpecializations = [
      "All Specializations",
      ...allDoctors
          .map((d) => d.specialization?.name ?? "")
          .where((s) => s.isNotEmpty)
          .toSet(),
    ];
    filteredDoctorsDropdown = ["All Doctors", ...allDoctors.map((d) => d.name)];
  }
  void _filterDoctors() {
    setState(() {
      filteredDoctors = allDoctors.where((doc) {
        final matchesHospital = selectedHospital == "All Hospitals"
            ? true
            : doc.hospital?.name == selectedHospital;
        final matchesSpecialization =
            selectedSpecialization == "All Specializations"
                ? true
                : doc.specialization?.name == selectedSpecialization;
        final matchesDoctor = selectedDoctor == "All Doctors"
            ? true
            : doc.name == selectedDoctor;
        return matchesHospital && matchesSpecialization && matchesDoctor;
      }).toList();
    });
  }
  void _updateSpecializationsByHospital(String hospitalName) {
    if (hospitalName == "All Hospitals") {
      filteredSpecializations = [
        "All Specializations",
        ...allDoctors
            .map((d) => d.specialization?.name ?? "")
            .where((s) => s.isNotEmpty)
            .toSet(),
      ];
    } else {
      filteredSpecializations = [
        "All Specializations",
        ...allDoctors
            .where((d) => d.hospital?.name == hospitalName)
            .map((d) => d.specialization?.name ?? "")
            .where((s) => s.isNotEmpty)
            .toSet(),
      ];
    }
    selectedSpecialization = "All Specializations";
    _updateDoctorsDropdown();
  }
  void _updateDoctorsDropdown() {
    filteredDoctorsDropdown = allDoctors
        .where((d) {
          final matchesHospital = selectedHospital == "All Hospitals"
              ? true
              : d.hospital?.name == selectedHospital;
          final matchesSpecialization =
              selectedSpecialization == "All Specializations"
                  ? true
                  : d.specialization?.name == selectedSpecialization;
          return matchesHospital && matchesSpecialization;
        })
        .map((d) => d.name)
        .toList();
    filteredDoctorsDropdown.insert(0, "All Doctors");
    selectedDoctor = "All Doctors";
  }
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_userInteracting) {
        _autoScroll(_doctorScrollController);
        _autoScroll(_hospitalScrollController);
      }
    });
  }
  void _autoScroll(ScrollController controller) {
    if (!controller.hasClients) return;
    final max = controller.position.maxScrollExtent;
    final current = controller.offset;
    double next = current + 1;
    if (next >= max) next = 0;
    controller.jumpTo(next);
  }
  void _onUserInteractionStart() {
    _userInteracting = true;
    _scrollTimer?.cancel();
  }
  void _onUserInteractionEnd() {
    _userInteracting = false;
    _startAutoScroll();
  }
  @override
  void dispose() {
    _scrollTimer?.cancel();
    _doctorScrollController.dispose();
    _hospitalScrollController.dispose();
    super.dispose();
  }

  // ... (دالة الـ build)
  @override
  Widget build(BuildContext context) {
    if (allDoctors.isEmpty || allHospitals.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bestDoctors = allDoctors.take(5).toList();
    final bestHospitals = allHospitals.map((h) => h.name).toList();
    final hospitalNames = ["All Hospitals", ...allHospitals.map((h) => h.name)];

    return Scaffold(
      appBar: AppBar(
        // ... (زي ما هو)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FiltersSection(
              // ... (زي ما هو)
              selectedHospital: selectedHospital,
              selectedSpecialization: selectedSpecialization,
              selectedDoctor: selectedDoctor,
              hospitals: hospitalNames,
              specializations: filteredSpecializations,
              doctorNames: filteredDoctorsDropdown,
              onHospitalChanged: (val) {
                setState(() {
                  selectedHospital = val!;
                  _updateSpecializationsByHospital(val);
                });
              },
              onSpecializationChanged: (val) {
                setState(() {
                  selectedSpecialization = val!;
                  _updateDoctorsDropdown();
                });
              },
              onDoctorChanged: (val) {
                setState(() => selectedDoctor = val!);
              },
              onSearchPressed: _filterDoctors,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredDoctors.isNotEmpty
                  ? SearchResultsList(
                      doctors: filteredDoctors,
                      selectedHospital: selectedHospital,
                      selectedSpecialty: selectedSpecialization,
                      user: widget.user, // (5) 🔥 مررنا اليوزر
                      jwt: widget.jwt,   // (6) 🔥 مررنا التوكن
                    )
                  : TopListsSection(
                      doctors: bestDoctors,
                      hospitals: bestHospitals,
                      doctorScrollController: _doctorScrollController,
                      hospitalScrollController: _hospitalScrollController,
                      onInteractionStart: _onUserInteractionStart,
                      onInteractionEnd: _onUserInteractionEnd,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}