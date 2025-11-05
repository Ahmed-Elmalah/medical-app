import 'package:flutter/material.dart';
import 'screens/role_selection_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Clinic App",
      home: RoleSelectionPage(),
    );
  }
}