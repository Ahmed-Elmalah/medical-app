import 'package:flutter/material.dart';

class PatientScheduleScreen extends StatelessWidget {
  const PatientScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,title: const Text("My Schedule",style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),)),
      body: const Center(
        child: Text(
          "Your upcoming appointments will appear here 📅",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
