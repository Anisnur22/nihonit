import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';

class LessonQuizPage extends StatefulWidget {
  final String level;
  final String lessonId;

  const LessonQuizPage({super.key, required this.level, required this.lessonId});

  @override
  State<LessonQuizPage> createState() => _LessonQuizPageState();
}

class _LessonQuizPageState extends State<LessonQuizPage> {
  List<Map<String, dynamic>> kanjiList = [];
  final FlutterTts flutterTts = FlutterTts();
  final GlobalKey _paintKey = GlobalKey();
  List<String> disabledOptions = [];
  List<Offset?> points = [];

  int currentIndex = 0;
  int subStage = 0;

  final List<String> subStages = ['warmup', 'drawing', 'quiz_p', 'quiz_m'];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    initTTS();
    loadKanji();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void initTTS() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.awaitSpeakCompletion(true);
  }

  void loadKanji() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('KanjiEntries')
        .where('level', isEqualTo: widget.level)
        .where('lessonId', isEqualTo: widget.lessonId)
        .orderBy('order')
        .get();

    final loadedKanji = snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    setState(() {
      kanjiList = loadedKanji;
    });
  }

  void nextStage() {
    setState(() {
      disabledOptions = [];
      points.clear();
      subStage++;
      if (subStage >= subStages.length) {
        subStage = 0;
        currentIndex++;
      }
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (kanjiList.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentIndex >= kanjiList.length) {
      _confettiController.play(); // 🎉 Trigger confetti

      return Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple],
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Quiz Complete!",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "You’ve completed this lesson!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    label: const Text("Back to Lessons"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBC002D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }

    final kanji = kanjiList[currentIndex];
    final stageType = subStages[subStage];

    Widget content;
    switch (stageType) {
      case 'warmup':
        content = buildWarmup(kanji);
        break;
      case 'drawing':
        content = buildDrawing(kanji);
        break;
      case 'quiz_p':
        content = buildMCQ(kanji, 'pronunciation');
        break;
      case 'quiz_m':
        content = buildMCQ(kanji, 'meaning');
        break;
      default:
        content = const Center(child: Text("Unexpected stage"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: content,
        ),
      ),
    );
  }

  Widget buildWarmup(Map<String, dynamic> kanji) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(kanji['character'], style: const TextStyle(fontSize: 100)),
        const SizedBox(height: 20),
        Text("Meaning: ${kanji['meaning']}", style: const TextStyle(fontSize: 18)),
        Text("Pronunciation: ${kanji['pronunciation']}", style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.green),
          onPressed: () => speak(kanji['pronunciation']),
        ),
        ElevatedButton(onPressed: nextStage, child: const Text("OK"))
      ],
    );
  }

  Widget buildDrawing(Map<String, dynamic> kanji) {
    final int requiredStrokes = kanji['strokeOrder'] ?? 1;
    final int completedStrokes = points.where((p) => p == null).length;
    final bool isReady = completedStrokes >= requiredStrokes;

    return Column(
      children: [
        Text(
          "Draw the character: ${kanji['character']}",
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text("Strokes: $completedStrokes / $requiredStrokes"),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: GestureDetector(
              onPanUpdate: (details) {
                final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  final localPosition = box.globalToLocal(details.globalPosition);
                  setState(() {
                    points.add(localPosition);
                  });
                }
              },
              onPanEnd: (_) {
                setState(() {
                  points.add(null); // End of a stroke
                });
              },
              child: Stack(
                children: [
                  if (kanji['strokeOrderUrl'] != null)
                    Positioned.fill(
                      child: Image.network(
                        kanji['strokeOrderUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('Image not available')),
                      ),
                    ),
                  Positioned.fill(
                    child: CustomPaint(
                      key: _paintKey,
                      painter: DrawingPainter(points),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isReady ? nextStage : null,
          child: const Text("Submit"),
        ),
      ],
    );
  }

  Widget buildMCQ(Map<String, dynamic> kanji, String field) {
    List<String> options = kanjiList.map((k) => k[field] as String).toSet().toList();
    options.shuffle();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(kanji['character'], style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 20),
        ...options.map((option) {
          final isDisabled = disabledOptions.contains(option);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        if (option == kanji[field]) {
                          nextStage();
                        } else {
                          setState(() {
                            disabledOptions.add(option);
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? Colors.grey : Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: Text(option, textAlign: TextAlign.center),
              ),
            ),
          );
        }).toList()
      ],
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Paint paintDrawing;

  DrawingPainter(this.points)
      : paintDrawing = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paintDrawing);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
