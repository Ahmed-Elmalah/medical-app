import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 🧩 الأقسام اللي قسمناها
import '../../widgets/filters_section.dart';
import '../../widgets/search_results_list.dart';
import '../../widgets/top_lists_section.dart';

// 🧠 الخدمات والموديلز
import '../../services/doctor_service.dart';
import '../../services/hospital_service.dart';
import '../../models/doctor_model.dart' hide HospitalModel;
import '../../models/hospital_model.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  // ✅ البيانات
  List<DoctorModel> allDoctors = [];
  List<HospitalModel> allHospitals = [];
  List<DoctorModel> filteredDoctors = [];

  // ✅ القوائم المنسدلة
  List<String> filteredSpecializations = [];
  List<String> filteredDoctorsDropdown = [];

  // ✅ الفلترة
  String selectedHospital = "All Hospitals";
  String selectedSpecialization = "All Specializations";
  String selectedDoctor = "All Doctors";

  // ✅ Auto Scroll
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

  // 🏥 تحميل المستشفيات من الـ API
  void _loadHospitals() async {
    allHospitals = await HospitalService.getHospitals();
    setState(() {});
  }

  // 👨‍⚕️ تحميل الدكاترة من الـ API
  void _loadDoctors() async {
    allDoctors = await DoctorService.getDoctors();
    _prepareInitialDropdowns();
    setState(() {});
  }

  // 🎯 تجهيز القوائم الأولية
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

  // 🔍 الفلترة الرئيسية
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

  // 🏥 تحديث التخصصات لما يختار مستشفى
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

  // 👨‍⚕️ تحديث أسماء الدكاترة حسب المستشفى والتخصص
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

  // 🌀 Auto Scroll Functions
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          "Patient Home",
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      // 🧩 المحتوى
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔽 فلترة
            FiltersSection(
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

            // 📋 نتائج البحث أو القوائم الرئيسية مع Scroll شغال
            Expanded(
              child: filteredDoctors.isNotEmpty
                  ? SearchResultsList(
                      doctors: filteredDoctors,
                      selectedHospital: selectedHospital,
                      selectedSpecialty: selectedSpecialization,
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
