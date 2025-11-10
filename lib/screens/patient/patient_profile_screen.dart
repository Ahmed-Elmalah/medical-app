// 📁 lib/screens/patient/patient_profile_screen.dart

import 'package:flutter/material.dart';
import '../../models/user_model.dart'; // (1) استدعاء الموديل
import '../role_selection_page.dart';

class PatientProfileScreen extends StatelessWidget {
  // (2) إضافة متغير عشان نستقبل بيانات اليوزر
  final UserModel user;

  const PatientProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // (3) عرضنا الاسم الحقيقي
            Text(
              user.username, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // (4) عرضنا الايميل الحقيقي
            Text(
              user.email,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // (5) عملنا لوج أوت حقيقي بيرجع لصفحة اختيار الدور
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => RoleSelectionPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}