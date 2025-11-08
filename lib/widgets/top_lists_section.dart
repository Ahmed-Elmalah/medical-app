// 📁 lib/widgets/top_lists_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/doctor_model.dart';
import 'top_doctors_list.dart';
import 'top_hospitals_list.dart';

class TopListsSection extends StatelessWidget {
  final List<DoctorModel> doctors;
  final List<String> hospitals;
  final ScrollController doctorScrollController;
  final ScrollController hospitalScrollController;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;

  const TopListsSection({
    Key? key,
    required this.doctors,
    required this.hospitals,
    required this.doctorScrollController,
    required this.hospitalScrollController,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        if (notification.direction == ScrollDirection.forward)
          onInteractionEnd();
        else
          onInteractionStart();
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 👨‍⚕️ Top Doctors
            TopDoctorsList(
              scrollController: doctorScrollController,
              doctors: doctors
                  .map((d) => {
                        "name": d.name,
                        "specialization": d.specialization?.name ?? "",
                        "hospital": d.hospital?.name ?? "",
                      })
                  .toList(),
            ),
            const SizedBox(height: 20),

            // 🏥 Top Hospitals
            TopHospitalsList(
              scrollController: hospitalScrollController,
              hospitals: hospitals,
            ),
          ],
        ),
      ),
    );
  }
}
