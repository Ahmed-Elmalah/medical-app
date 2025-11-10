// 📁 lib/screens/patient/register_page.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // (1) استدعاء الـ Service الجديد

// (2) حولناها لـ StatefulWidget عشان الـ loading
class PatientRegisterPage extends StatefulWidget {
  @override
  _PatientRegisterPageState createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService(); // (3) عملنا instance من الـ Service
  bool _isLoading = false; // (4) متغير عشان نتابع حالة الـ loading

  // (5) الدالة اللي هتتنفذ لما نضغط "Sign Up"
  void _handleRegister() async {
    // لو بنحمل أصلاً، منعملش حاجة
    if (_isLoading) return;

    // بنجيب البيانات من الـ TextFields
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // نتأكد إن مفيش حاجة فاضية
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // نبدأ الـ loading
    setState(() => _isLoading = true);

    // ننادي الـ API
    final result = await _authService.registerPatient(
      name: name,
      email: email,
      password: password,
    );

    // نوقف الـ loading
    setState(() => _isLoading = false);

    // نتحقق من النتيجة
    if (result['success']) {
      // لو نجح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully! Please login."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // نرجع لصفحة اختيار الـ Role
    } else {
      // لو فشل (نعرض الرسالة اللي جاية من Strapi)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${result['message']}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Full Name (as Username)"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // (6) ربطنا الزرار بالدالة بتاعتنا
              onPressed: _handleRegister,
              // (7) بنعرض loading indicator لو _isLoading بـ true
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text("Sign Up", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}