import 'package:coolapp/pages/intro_page.dart';
import 'package:flutter/material.dart';

class SuccessfulPage extends StatelessWidget {
  const SuccessfulPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar entirely
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkmark Icon
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFFBC002D),
              size: 80,
            ),
            SizedBox(height: 20),
            // Success Text
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your account has been created',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 40),
            // Continue Button
            GestureDetector(
              onTap: () {
                // Navigate to the HomePage and remove the back button
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => IntroPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Color(0xFFBC002D),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
