import 'package:flutter/material.dart';

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Doctor Schedule",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text(
          "Here will be the doctor's available times and hospitals 🏥",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
