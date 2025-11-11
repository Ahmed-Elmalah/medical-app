// 📁 lib/screens/doctor/home_page.dart
// (النسخة اللي بتمرر الداتا لـ DoctorPatientsScreen)

import 'package:flutter/material.dart';
import 'package:project_2/models/doctor_model.dart';
import 'package:project_2/models/user_model.dart';
import 'doctor_profile_screen.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_patients_screen.dart'; // (1) 🔥 استدعاء الشاشة

class DoctorHomePage extends StatefulWidget {
  // (2) 🔥 ضفنا المتغيرات دي (زي ما عملنا في الـ Schedule)
  final DoctorModel doctor;
  final UserModel user;
  final String jwt;

  const DoctorHomePage({
    Key? key,
    required this.doctor,
    required this.user,
    required this.jwt, 
  }) : super(key: key);

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  int _currentIndex = 0;
  
  late final List<Widget> _pages; 

  @override
  void initState() {
    super.initState();
    // (3) 🔥 جهزنا الصفحات ومررنا الداتا
    _pages = [
      DoctorScheduleScreen(
        doctor: widget.doctor,
        token: widget.jwt,
      ),
      // (4) 🔥 مررنا الداتا لشاشة "المرضى"
      DoctorPatientsScreen(
        doctor: widget.doctor,
        token: widget.jwt,
      ),
      const DoctorProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}