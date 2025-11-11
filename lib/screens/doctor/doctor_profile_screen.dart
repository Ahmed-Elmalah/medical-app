// 📁 lib/screens/doctor/doctor_profile_screen.dart
// (الديزاين الجديد والبيانات)

import 'package:flutter/material.dart';
import 'package:project_2/models/doctor_model.dart';
import 'package:project_2/models/user_model.dart';
import '../unified_login_page.dart'; // (عشان اللوج آوت)

class DoctorProfileScreen extends StatelessWidget {
  // (1) 🔥 بنستقبل بيانات الدكتور واليوزر
  final DoctorModel doctor;
  final UserModel user;

  const DoctorProfileScreen({
    Key? key,
    required this.doctor,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // (بنجيب البيانات عشان نعرضها)
    final String doctorName = doctor.name;
    final String email = user.email;
    final String specialization = doctor.specialization?.name ?? "Not Set";
    final String hospital = doctor.hospital?.name ?? "Not Set";
    
    // (صورة افتراضية)
    final String imageUrl = doctor.imageUrl != null
        ? "http://localhost:1337${doctor.imageUrl}"
        : "https://cdn-icons-png.flaticon.com/512/3774/3774299.png";


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // (1) 🔥 صورة البروفايل
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) {}, // (بيمنع إيرور لو الصورة مش موجودة)
              child: imageUrl.contains("flaticon") // (لو بيستخدم الصورة الافتراضية)
                  ? Icon(Icons.local_hospital, size: 60, color: Colors.blue.shade200)
                  : null,
            ),
            const SizedBox(height: 20),

            // (2) 🔥 اسم الدكتور
            Text(
              doctorName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // (3) 🔥 الإيميل
            Text(
              email,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // (4) 🔥 باقي التفاصيل
            _buildProfileInfoTile(
              icon: Icons.medical_services_outlined,
              title: "Specialization",
              value: specialization,
              color: Colors.blueAccent,
            ),
            _buildProfileInfoTile(
              icon: Icons.local_hospital_outlined,
              title: "Primary Hospital",
              value: hospital,
              color: Colors.redAccent,
            ),
            _buildProfileInfoTile(
              icon: Icons.phone_outlined,
              title: "Phone (from Hospital)",
              value: doctor.hospital?.phone ?? "Not Set",
              color: Colors.green,
            ),
            
            const SizedBox(height: 30),

            // (5) 🔥 زرار اللوج آوت
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // (بيرجع لشاشة اللوجين ويمسح كل اللي فات)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => UnifiedLoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // (ويدجت مساعد للديزاين)
  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}