import 'package:flutter/material.dart';

import 'createpractice_page.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10),

              Text(
                'PRACTICE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),

              SizedBox(height: 10),

              //Buttons
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePracticePage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                      child: Text(
                        'Create Practice Deck',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
