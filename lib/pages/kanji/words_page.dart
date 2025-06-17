import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_page.dart'; // This should still work as it uses the new lesson structure

class WordsPage extends StatelessWidget {
  const WordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),

              _buildLevelButton(context, 'level1', 'Level 1', 'JLPT N5'),
              _buildLevelButton(context, 'level2', 'Level 2', 'JLPT N4'),
              _buildLevelButton(context, 'level3', 'Level 3', 'JLPT N3'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level, String levelName, String jlpt) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('KanjiLessons')
          .where('level', isEqualTo: level)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching lessons'));
        }

        final lessonDocs = snapshot.data?.docs ?? [];
        final bool isLevelLocked = lessonDocs.isEmpty;

        return GestureDetector(
          onTap: () {
            if (!isLevelLocked) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonsPage(level: level),
                ),
              );
            } else {
              showLockDialog(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 98,
                  decoration: BoxDecoration(
                    color: isLevelLocked
                        ? const Color(0xFFBC002D).withOpacity(0.4)
                        : const Color(0xFFBC002D),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          levelName,
                          style: TextStyle(
                            color: isLevelLocked
                                ? const Color.fromARGB(255, 223, 220, 220)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                        ),
                        Text(
                          jlpt,
                          style: TextStyle(
                            color: isLevelLocked
                                ? const Color.fromARGB(255, 223, 220, 220)
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLevelLocked)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Level Locked'),
        content: const Text('This level is currently locked. Please complete the previous levels to unlock it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
