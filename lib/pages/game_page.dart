import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE1D5B9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),
              const Text(
                'GAME',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
