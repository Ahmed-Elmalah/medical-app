import 'package:flutter/material.dart';
import '../../widgets/patient_card.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _patients = const [
    {
      "name": "Mahmoud Ali",
      "hospital": "Cairo Medical Center",
      "date": "Tue, Nov 5 - 3:00 PM",
      "image":
          "https://imgs.search.brave.com/OH2XNLPZJSsxN-1hvbWvX-d54pbVDIxrGz14v-qmLaU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTQw/Njk1NjE0Ni9waG90/by91bnJlY29nbml6/YWJsZS1wYXRpZW50/LWluLWhvc3BpdGFs/LWdvd24td2FpdHMt/Zm9yLXRlc3QtcmVz/dWx0cy5qcGc_cz02/MTJ4NjEyJnc9MCZr/PTIwJmM9aXZ1bnYz/eVdURktveWhIM2JT/NWZxeVVETGtLQmgw/ekFOdkRnbHpmRTgt/MD0",
    },
    {
      "name": "Adham Mohamed",
      "hospital": "El Salam Hospital",
      "date": "Tue, Nov 5 - 5:00 PM",
      "image": "images/2.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            "My Patients",
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _patients
                .map(
                  (p) => PatientCard(
                    name: p["name"]!,
                    hospital: p["hospital"]!,
                    date: p["date"]!,
                    imageUrl: p["image"]!,
                    onTap: () {
                      // تقدر تفتح صفحة تفاصيل المريض هنا
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
