import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LessonQuizPage extends StatefulWidget {
  final String level;
  final String lessonId;

  const LessonQuizPage({super.key, required this.level, required this.lessonId});

  @override
  State<LessonQuizPage> createState() => _LessonQuizPageState();
}

class _LessonQuizPageState extends State<LessonQuizPage> {
  List<Map<String, dynamic>> kanjiList = [];
  int stage = 0; // 0 to 7 per pair
  int currentPair = 0;
  final FlutterTts flutterTts = FlutterTts();
  List<String> disabledOptions = [];
  List<Offset?> points = []; // Store the drawing points here

  @override
  void initState() {
    super.initState();
    initTTS();
    loadKanji();
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
      final data = doc.data() as Map<String, dynamic>;
      return data;
    }).toList();

    setState(() {
      kanjiList = loadedKanji;
    });
  }

  void nextStage() {
    setState(() {
      disabledOptions = []; // reset disabled options for next stage
      stage++;
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (kanjiList.length < currentPair + 2) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE1D5B9),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not enough kanji to start quiz.'),
              Text('Loaded ${kanjiList.length} kanji for lesson ${widget.lessonId}')
            ],
          ),
        ),
      );
    }

    final kanji1 = kanjiList[currentPair];
    final kanji2 = kanjiList[currentPair + 1];
    final kanji3 = kanjiList[currentPair + 2];
    final kanji4 = kanjiList[currentPair + 3];

    Widget content;
    switch (stage) {
      case 0:
        content = buildWarmup(kanji1);
        break;
      case 1:
        content = buildWarmup(kanji2);
        break;
      case 2:
        content = buildDrawing(kanji1);
        break;
      case 3:
        content = buildDrawing(kanji2);
        break;
      case 4:
        content = buildMCQ(kanji1, 'pronunciation');
        break;
      case 5:
        content = buildMCQ(kanji1, 'meaning');
        break;
      case 6:
        content = buildMCQ(kanji2, 'pronunciation');
        break;
      case 7:
        content = buildMCQ(kanji2, 'meaning');
        break;
      case 8:
        content = buildWarmup(kanji3); // Handle pair 3 warmup
        break;
      case 9:
        content = buildWarmup(kanji4); // Handle pair 4 warmup
        break;
      case 10:
        content = buildDrawing(kanji3); // Handle pair 3 drawing
        break;
      case 11:
        content = buildDrawing(kanji4); // Handle pair 4 drawing
        break;
      case 12:
        content = buildMCQ(kanji3, 'pronunciation'); // Handle pair 3 MCQ
        break;
      case 13:
        content = buildMCQ(kanji3, 'meaning'); // Handle pair 3 MCQ
        break;
      case 14:
        content = buildMCQ(kanji4, 'pronunciation'); // Handle pair 4 MCQ
        break;
      case 15:
        content = buildMCQ(kanji4, 'meaning'); // Handle pair 4 MCQ
        break;
      default:
        content = const Center(child: Text("Quiz Finished!"));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Draw the character: ${kanji['character']}", style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                points.add(details.localPosition); // Add points when user draws
              });
            },
            onPanEnd: (details) {
              setState(() {
                points.add(null); // Add null to indicate the end of a line
              });
            },
            child: CustomPaint(
              size: Size(double.infinity, 300),
              painter: DrawingPainter(points, kanji['character']), // Pass the character to display
            ),
          ),
        ),
        ElevatedButton(onPressed: nextStage, child: const Text("Submit"))
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
  final List<Offset?> points; // List of points being drawn
  final String character;
  final Paint paintDrawing;

  DrawingPainter(this.points, this.character)
      : paintDrawing = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the gray square for canvas background
    final paintBackground = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(50, 50) & Size(size.width - 100, size.height - 100), paintBackground);

    // Draw the character in the center
    final textStyle = TextStyle(color: Colors.black, fontSize: 50);
    final textPainter = TextPainter(
      text: TextSpan(text: character, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));

    // Draw the drawing points
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paintDrawing); // Draw line between points
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is DrawingPainter) {
      return oldDelegate.points != points; // Repaint if points list has changed
    }
    return false;
  }
}
