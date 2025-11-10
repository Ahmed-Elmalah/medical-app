// 📁 lib/screens/patient/main_page.dart

import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'patient_home_screen.dart';
import 'patient_profile_screen.dart';
import 'patient_schedule_screen.dart';

class PatientMainScreen extends StatefulWidget {
  final UserModel user;
  final String jwt; // (1) 🔥 ضفنا التوكن هنا

  const PatientMainScreen({
    Key? key,
    required this.user,
    required this.jwt, // (2) 🔥 ضفناه في الـ constructor
  }) : super(key: key);

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PatientHomeScreen(user: widget.user, jwt: widget.jwt),
      // (1) 🔥 مررنا اليوزر والتوكن
      PatientScheduleScreen(user: widget.user, jwt: widget.jwt),
      PatientProfileScreen(user: widget.user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Schedule',
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
