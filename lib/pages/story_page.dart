import 'package:flutter/material.dart';
import 'home_page.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

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

              const Text(
                'STORY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),

              SizedBox(height: 10),

              //Buttons
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 98,
                    decoration: BoxDecoration(
                      color: Color(0xFFBC002D),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Story Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                            ),
                          ),
                        ],
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
