// 📁 lib/screens/patient/login_page.dart

import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_welcome_dialog.dart';
import 'main_page.dart';

class PatientLoginPage extends StatefulWidget {
  @override
  _PatientLoginPageState createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // (1) 🔥 عدّلنا الدالة دي عشان تستقبل التوكن (jwt)
  void _showWelcomeAndGoHome(BuildContext context, UserModel user, String jwt) {
    showWelcomeDialog(
      context,
      "Welcome Back, ${user.username}!",
      "We're glad to see you again 💙",
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); 
      Navigator.pushReplacement(
        context,
        // (2) 🔥 بقينا نمرر اليوزر والتوكن للشاشة الرئيسية
        MaterialPageRoute(builder: (_) => PatientMainScreen(user: user, jwt: jwt)),
      );
    });
  }

  void _handleLogin() async {
    if (_isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (result['success']) {
      final UserModel user = result['user'];
      final String jwt = result['jwt']; // (3) 🔥 جبنا التوكن هنا

      if (user.roleName.toLowerCase() == 'patient') {
        // (4) 🔥 مررنا التوكن للدالة
        _showWelcomeAndGoHome(context, user, jwt);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Access Denied: You are not a patient."),
              backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: ${result['message']}"),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient Login",
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
              onPressed: _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}