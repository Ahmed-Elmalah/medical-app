import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../data/dummy_doctors.dart';
import '../../widgets/doctor_card.dart';

import '../../widgets/filters_section.dart';
import '../../widgets/top_doctors_list.dart';
import '../../widgets/top_hospitals_list.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String selectedHospital = "All Hospitals";
  String selectedSpecialization = "All Specializations";
  String selectedDoctor = "All Doctors";
  List<Map<String, String>> filteredDoctors = [];

  late ScrollController _doctorScrollController;
  late ScrollController _hospitalScrollController;
  Timer? _scrollTimer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _doctorScrollController = ScrollController();
    _hospitalScrollController = ScrollController();
    _startAutoScroll();
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
    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;

    double next = currentScroll + 1;
    if (next >= maxScroll) {
      next = 0;
    }

    controller.jumpTo(next);
  }

  void _onUserInteractionStart() {
    _userInteracting = true;
    _scrollTimer?.cancel();
  }

  void _onUserInteractionEnd() {
    _userInteracting = true;
    Future.delayed(const Duration(seconds: 3), () {
      _userInteracting = false;
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _doctorScrollController.dispose();
    _hospitalScrollController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    setState(() {
      filteredDoctors = dummyDoctors.where((doc) {
        final matchesHospital =
            selectedHospital == "All Hospitals" || doc["hospital"] == selectedHospital;
        final matchesSpecialization =
            selectedSpecialization == "All Specializations" ||
            doc["specialization"] == selectedSpecialization;
        final matchesDoctor =
            selectedDoctor == "All Doctors" || doc["name"] == selectedDoctor;
        return matchesHospital && matchesSpecialization && matchesDoctor;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hospitals = ["All Hospitals", ...dummyDoctors.map((d) => d["hospital"]!).toSet()];
    final specializations =
        ["All Specializations", ...dummyDoctors.map((d) => d["specialization"]!).toSet()];
    final doctorNames = [
      "All Doctors",
      ...dummyDoctors
          .where((d) =>
              (selectedHospital == "All Hospitals" || d["hospital"] == selectedHospital) &&
              (selectedSpecialization == "All Specializations" ||
                  d["specialization"] == selectedSpecialization))
          .map((d) => d["name"]!)
          .toSet()
    ];

    final bestDoctors = dummyDoctors.take(5).toList();
    final bestHospitals = dummyDoctors
        .map((d) => d["hospital"]!)
        .toSet()
        .toList()
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Patient Home",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FiltersSection(
              selectedHospital: selectedHospital,
              selectedSpecialization: selectedSpecialization,
              selectedDoctor: selectedDoctor,
              hospitals: hospitals,
              specializations: specializations,
              doctorNames: doctorNames,
              onHospitalChanged: (val) => setState(() => selectedHospital = val!),
              onSpecializationChanged: (val) => setState(() => selectedSpecialization = val!),
              onDoctorChanged: (val) => setState(() => selectedDoctor = val!),
              onSearchPressed: _filterDoctors,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredDoctors.isEmpty
                  ? NotificationListener<UserScrollNotification>(
                      onNotification: (notification) {
                        if (notification.direction == ScrollDirection.forward) {
                          _onUserInteractionEnd();
                        } else {
                          _onUserInteractionStart();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TopDoctorsList(
                              scrollController: _doctorScrollController,
                              doctors: bestDoctors,
                            ),
                            const SizedBox(height: 20),
                            TopHospitalsList(
                              scrollController: _hospitalScrollController,
                              hospitals: bestHospitals,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDoctors[index];
                        return DoctorCard(
                          name: doc["name"]!,
                          specialization: doc["specialization"]!,
                          hospital: doc["hospital"]!,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
