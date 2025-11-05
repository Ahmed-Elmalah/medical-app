import 'package:flutter/material.dart';

void showWelcomeDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        padding: EdgeInsets.all(22),
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12),
              child: Icon(Icons.waving_hand, color: Colors.blueAccent, size: 46),
            ),
            SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent)),
            SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54)),
          ],
        ),
      ),
    ),
  );
}
