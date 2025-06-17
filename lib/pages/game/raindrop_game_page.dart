import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ NEW

class RaindropGamePage extends StatefulWidget {
  final String scriptType;
  final String? kanjiMode;

  const RaindropGamePage({super.key, required this.scriptType, this.kanjiMode});

  @override
  State<RaindropGamePage> createState() => _RaindropGamePageState();
}

class _RaindropGamePageState extends State<RaindropGamePage> {
  List<_Droplet> droplets = [];
  int score = 0;
  int lives = 3;
  final TextEditingController inputController = TextEditingController();
  late Timer spawnTimer;
  late Timer fallTimer;
  late Timer difficultyTimer;
  final Random random = Random();

  String dropletUrl = '';
  String poppedUrl = '';
  bool assetsLoaded = false;

  int difficultyLevel = 1;
  Duration spawnInterval = const Duration(seconds: 2);

  final AudioPlayer audioPlayer = AudioPlayer(); // ✅ NEW

  @override
  void initState() {
    super.initState();
    _loadAssets().then((_) {
      spawnDroplets();
      startFalling();
      startDifficultyIncrease();
    });
  }

  Future<void> _loadAssets() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('raindropAssets')
        .doc('default')
        .get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        dropletUrl = data['dropletUrl'] ?? '';
        poppedUrl = data['poppedUrl'] ?? '';
        assetsLoaded = true;
      });
    }
  }

  void spawnDroplets() {
    spawnTimer = Timer.periodic(spawnInterval, (_) async {
      int dropletsToSpawn = (difficultyLevel >= 5) ? 2 : 1;
      for (int i = 0; i < dropletsToSpawn; i++) {
        final doc = await _getRandomCharacterDoc();
        if (doc != null) {
          final text = doc['text'];
          final answer = doc['answer'];

          if (text.isNotEmpty && answer.isNotEmpty) {
            final droplet = _Droplet(
              text: text,
              answer: answer,
              x: random.nextDouble() * 300,
              y: 0,
              popped: false,
            );
            setState(() => droplets.add(droplet));
          }
        }
      }
    });
  }

  void _restartSpawnTimer() {
    spawnTimer.cancel();
    spawnDroplets();
  }

  void startDifficultyIncrease() {
    difficultyTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (spawnInterval > const Duration(milliseconds: 600)) {
        difficultyLevel++;
        spawnInterval -= const Duration(milliseconds: 200);
        _restartSpawnTimer();
      }
    });
  }

  Future<Map<String, dynamic>?> _getRandomCharacterDoc() async {
    String typeToUse = widget.scriptType;

    if (widget.scriptType == 'all') {
      const options = ['hiragana', 'katakana', 'kanji'];
      typeToUse = options[random.nextInt(options.length)];
    }

    if (typeToUse == 'kanji') {
      final snapshot =
          await FirebaseFirestore.instance.collection('KanjiEntries').get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs[random.nextInt(snapshot.docs.length)];
      return {
        'text': doc['character'] ?? '',
        'answer': doc['meaning'] ?? '',
      };
    } else {
      final snapshot = await FirebaseFirestore.instance
          .collection('hiraganaGujuon')
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs[random.nextInt(snapshot.docs.length)];
      return {
        'text': typeToUse == 'katakana'
            ? doc['katakana'] ?? ''
            : doc['hiragana'] ?? '',
        'answer': doc['pronunciation'] ?? '',
      };
    }
  }

  void startFalling() {
    fallTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        for (final d in droplets) {
          d.y += 5;
        }
        droplets.removeWhere((d) {
          if (d.y > 600) {
            lives--;
            return true;
          }
          return false;
        });
        if (lives <= 0) {
          _endGame();
        }
      });
    });
  }

  void _checkAnswer(String input) async {
    if (input.isEmpty) return;

    final matched = droplets.indexWhere(
      (d) => d.answer.toLowerCase() == input.trim().toLowerCase(),
    );

    if (matched != -1) {
      setState(() {
        droplets[matched].popped = true;
        score += 50;
      });

      // ✅ PLAY SOUND EFFECT
      await audioPlayer.play(AssetSource('sounds/correct.mp3'));

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && matched < droplets.length) {
          setState(() {
            droplets.removeAt(matched);
          });
        }
      });
    }

    inputController.clear();
  }

  void _endGame() async {
    spawnTimer.cancel();
    fallTimer.cancel();
    difficultyTimer.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final gameStatsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gamestats')
          .doc(widget.scriptType);

      final existing = await gameStatsRef.get();

      if (!existing.exists || (existing.data()?['score'] ?? 0) < score) {
        await gameStatsRef.set({
          'mode': widget.scriptType,
          'score': score,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Your score: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to menu
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    spawnTimer.cancel();
    fallTimer.cancel();
    difficultyTimer.cancel();
    inputController.dispose();
    audioPlayer.dispose(); // ✅ Dispose player
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.lightBlue[100],
    appBar: AppBar(
    backgroundColor: const Color(0xFFE1D5B9),
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, size: 40),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: const Text(
      "Raindrop Quiz",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
  ),

    body: !assetsLoaded
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // Score & Lives
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("❤️ ", style: TextStyle(fontSize: 20)),
                      Text("$lives", style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      const Text("⭐ ", style: TextStyle(fontSize: 20)),
                      Text("$score", style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),

              // Droplets
              ...droplets.map(
                (d) => Positioned(
                  left: d.x,
                  top: d.y,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          d.popped ? poppedUrl : dropletUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.water_drop, size: 40),
                        ),
                        Text(
                          d.popped ? '' : d.text,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Input field (cute style)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextField(
                        controller: inputController,
                        onSubmitted: _checkAnswer,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type your answer...",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
  );
}
}

class _Droplet {
  String text;
  String answer;
  double x;
  double y;
  bool popped;

  _Droplet({
    required this.text,
    required this.answer,
    required this.x,
    required this.y,
    this.popped = false,
  });
}
