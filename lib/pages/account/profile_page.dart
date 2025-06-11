import 'package:coolapp/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';// Import the LoginPage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Log out function
  Future<void> _logOut(BuildContext context) async {
    try {
      // Sign out the user from Firebase
      await FirebaseAuth.instance.signOut();

      // After successful logout, navigate to the LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroPage()), // Navigate to LoginPage
      );
    } catch (e) {
      // Handle any errors that might occur during log out
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: Color(0xFFE1D5B9),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for profile info
            Icon(
              Icons.account_circle,
              size: 120,
              color: Color(0xFFBC002D),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to your profile!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Log Out Button
            GestureDetector(
              onTap: () => _logOut(context), // Call log out function
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFFBC002D), // Red color for the button
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
