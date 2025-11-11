import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../services/auth_service.dart';
import '../services/doctor_service.dart';
import 'patient/main_page.dart';
import 'doctor/home_page.dart';
import 'unified_signup_page.dart';

class UnifiedLoginPage extends StatefulWidget {
  @override
  _UnifiedLoginPageState createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.unifiedLogin(
      email: email,
      password: password,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final user = result['user'];
      final role = result['role'];
      final jwt = result['jwt'];

      print("✅ Login successful - Role: $role, User ID: ${user.id}");

      if (role == 'doctor') {
        try {
          // جيب بيانات الدكتور الإضافية
          final doctorData = await DoctorService.getDoctorByUserEmail(
            user.email,
          );
          // print("🎯 Doctor data loaded: ${doctorData.name}");

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorHomePage(
                doctor: doctorData,
                user: user,
                jwt: jwt,
              ), // 🔥 ضيف التوكن هنا
            ),
          );
        } catch (e) {
          print("⚠️ Doctor data not found: $e");
          // لو بيانات الدكتور مش موجودة، استخدم بيانات أساسية
          final basicDoctor = DoctorModel(
            id: user.id,
            name: user.username,
            email: user.email,
            hospital: null,
            specialization: null,
            workingHours: null,
            workingDays: null,
            imageUrl: null,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorHomePage(doctor: basicDoctor, user: user, jwt: '',),
            ),
          );
        }
      } else if (role == 'patient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatientMainScreen(user: user, jwt: jwt),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${result['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Login",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              onPressed: _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UnifiedSignupPage()),
                );
              },
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
