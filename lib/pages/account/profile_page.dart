import 'package:coolapp/pages/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  bool isLoading = true;
  List<Map<String, dynamic>> topPlayers = [];
  String selectedScript = 'hiragana';

  final Map<String, String> scriptLabels = {
    'hiragana': 'Hiragana',
    'katakana': 'Katakana',
    'kanji': 'Kanji',
    'all': 'All',
  };

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchLeaderboard();
  }

  Future<void> fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = userDoc.data();
        setState(() {
          username = data?['username'] ?? 'User';
        });
      }
    } catch (e) {
      setState(() {
        username = 'User';
      });
    }
  }

  Future<void> fetchLeaderboard() async {
    setState(() {
      isLoading = true;
    });

    final firestore = FirebaseFirestore.instance;
    final usersSnapshot = await firestore.collection('users').get();

    List<Map<String, dynamic>> scores = [];

    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;
      final userData = userDoc.data();

      final userUsername = userData.containsKey('username') && userData['username'] != null
          ? userData['username']
          : userId;

      final gameStatDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('gamestats')
          .doc(selectedScript)
          .get();

      if (gameStatDoc.exists) {
        final data = gameStatDoc.data();
        final score = data?['score'] ?? 0;

        scores.add({
          'username': userUsername,
          'score': score,
        });
      }
    }

    scores.sort((a, b) => b['score'].compareTo(a['score']));

    setState(() {
      topPlayers = scores.take(5).toList();
      isLoading = false;
    });
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: const Color(0xFFE1D5B9),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: const Color(0xFFBC002D),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, $username!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Dropdown for script selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.leaderboard, color: Color(0xFFBC002D)),
                      const SizedBox(width: 8),
                      const Text("Top scores for: ",
                          style: TextStyle(fontSize: 16)),
                      DropdownButton<String>(
                        value: selectedScript,
                        items: scriptLabels.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedScript = value;
                            });
                            fetchLeaderboard();
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: topPlayers.isEmpty
                        ? const Text("No scores yet.")
                        : Column(
                            children: topPlayers.asMap().entries.map((entry) {
                              int index = entry.key;
                              var player = entry.value;
                              String emoji = switch (index) {
                                0 => "🥇",
                                1 => "🥈",
                                2 => "🥉",
                                _ => "🎮",
                              };
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Text(emoji,
                                      style: const TextStyle(fontSize: 24)),
                                  title: Text(player['username'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  trailing: Text("⭐ ${player['score']}",
                                      style: const TextStyle(fontSize: 16)),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 40),

                  // Logout Button
                  GestureDetector(
                    onTap: () => _logOut(context),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBC002D),
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
