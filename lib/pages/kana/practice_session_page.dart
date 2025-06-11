import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for current user
import 'dart:math';
import 'practice_summary_page.dart'; // Adjust the path as needed

class PracticeSessionPage extends StatefulWidget {
  final List<String> selectedHiragana;
  final List<String> selectedKatakana;
  final String difficulty;

  const PracticeSessionPage({
    super.key,
    required this.selectedHiragana,
    required this.selectedKatakana,
    required this.difficulty,
  });

  @override
  State<PracticeSessionPage> createState() => _PracticeSessionPageState();
}

class _PracticeSessionPageState extends State<PracticeSessionPage> {
  late List<Map<String, String>> allKana; // {'id': ..., 'script': ...}
  late List<String> allSelectedCards; // Combined list of all selected card IDs
  Map<String, Map<String, String>> kanaDataMap = {}; // id -> {'hiragana': ..., 'katakana': ...}

  int currentIndex = 0;
  bool loading = true;

  String? selectedAnswer; // for easy mode option selected
  bool answered = false;
  bool correctAnswerSelected = false;

  List<String> options = [];

  // Track results: { 'characterId': { 'hiraganaPass': x, 'hiraganaFail': y, ... } }
  Map<String, Map<String, int>> practiceResults = {};

  final Random random = Random();

  // For hard mode text input
  final TextEditingController _textController = TextEditingController();
  bool showCorrectAnswer = false;

  @override
  void initState() {
    super.initState();

    allKana = [
      ...widget.selectedHiragana.map((id) => {'id': id, 'script': 'hiragana'}),
      ...widget.selectedKatakana.map((id) => {'id': id, 'script': 'katakana'}),
    ];
    allKana.shuffle();

    // Combine both selected lists into one for summary page
    allSelectedCards = [
      ...widget.selectedHiragana,
      ...widget.selectedKatakana,
    ];

    _fetchKanaData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchKanaData() async {
    final firestore = FirebaseFirestore.instance;

    final docs = await Future.wait(allKana.map((entry) =>
      firestore.collection('hiraganaGujuon').doc(entry['id']!.toLowerCase()).get()
    ));

    final Map<String, Map<String, String>> map = {};
    for (var doc in docs) {
      if (doc.exists) {
        final data = doc.data()!;
        map[doc.id] = {
          'hiragana': data['hiragana'] ?? '',
          'katakana': data['katakana'] ?? '',
        };
      }
    }

    setState(() {
      kanaDataMap = map;
      loading = false;
      if (widget.difficulty == 'easy') {
        _generateOptions();
      }
    });
  }

  void _generateOptions() {
    if (allKana.isEmpty) {
      options = [];
      return;
    }

    final currentKana = allKana[currentIndex];
    final correctAnswer = currentKana['id']!;

    // Collect unique wrong options
    final wrongOptionsSet = allKana
        .where((entry) => entry['id'] != correctAnswer)
        .map((e) => e['id']!)
        .toSet();

    final wrongOptions = wrongOptionsSet.toList();
    wrongOptions.shuffle();

    final wrongAnswers = wrongOptions.take(3).toList();

    options = [...wrongAnswers, correctAnswer];
    options.shuffle();

    selectedAnswer = null;
    answered = false;
    correctAnswerSelected = false;
  }

  void _onOptionSelected(String option) {
    if (answered) return;

    final currentKana = allKana[currentIndex];
    final id = currentKana['id']!;
    final script = currentKana['script']!;
    final correct = (option == id);

    setState(() {
      selectedAnswer = option;
      answered = true;
      correctAnswerSelected = correct;

      practiceResults[id] ??= {
        'hiraganaPass': 0,
        'hiraganaFail': 0,
        'katakanaPass': 0,
        'katakanaFail': 0,
      };

      final passField = script + 'Pass';
      final failField = script + 'Fail';

      if (correct) {
        practiceResults[id]![passField] = (practiceResults[id]![passField] ?? 0) + 1;
      } else {
        practiceResults[id]![failField] = (practiceResults[id]![failField] ?? 0) + 1;
      }
    });
  }

  void _onSubmitHardAnswer() {
    if (answered) return;

    final currentKana = allKana[currentIndex];
    final id = currentKana['id']!;
    final script = currentKana['script']!;
    final userAnswer = _textController.text.trim().toLowerCase();

    final correct = (userAnswer == id.toLowerCase());

    setState(() {
      answered = true;
      correctAnswerSelected = correct;

      practiceResults[id] ??= {
        'hiraganaPass': 0,
        'hiraganaFail': 0,
        'katakanaPass': 0,
        'katakanaFail': 0,
      };

      final passField = script + 'Pass';
      final failField = script + 'Fail';

      if (correct) {
        practiceResults[id]![passField] = (practiceResults[id]![passField] ?? 0) + 1;
      } else {
        practiceResults[id]![failField] = (practiceResults[id]![failField] ?? 0) + 1;
      }

      // Show correct answer if wrong
      showCorrectAnswer = !correct;
    });
  }

  Future<void> _savePracticeResults() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final statsCollectionRef = userDocRef.collection('practiceStats');

    practiceResults.forEach((characterId, stats) {
      final docRef = statsCollectionRef.doc(characterId);
      stats.forEach((field, value) {
        batch.set(docRef, {
          field: FieldValue.increment(value),
        }, SetOptions(merge: true));
      });
    });

    await batch.commit();
  }

  void _nextQuestion() async {
    if (!answered) return;

    _textController.clear();
    showCorrectAnswer = false;

    if (currentIndex < allKana.length - 1) {
      setState(() {
        currentIndex++;
        if (widget.difficulty == 'easy') {
          _generateOptions();
        }
        answered = false;
        correctAnswerSelected = false;
        selectedAnswer = null;
      });
    } else {
      await _savePracticeResults();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeSummaryPage(
            practiceResults: practiceResults,
            totalSelectedCards: allSelectedCards.length,
            selectedCards: allSelectedCards,
          ),
        ),
      );
    }
  }

  Color _optionColor(String option) {
    if (!answered) return Colors.white;

    final currentKana = allKana[currentIndex];

    if (option == selectedAnswer) {
      return option == currentKana['id'] ? Colors.green.shade300 : Colors.red.shade300;
    } else if (option == currentKana['id']) {
      return Colors.green.shade300;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          backgroundColor: const Color(0xFFE1D5B9),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (allKana.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice Session'),
          backgroundColor: const Color(0xFFE1D5B9),
        ),
        body: const Center(child: Text('No kana selected to practice')),
      );
    }

    final currentKana = allKana[currentIndex];
    final id = currentKana['id']!;
    final script = currentKana['script']!;
    final kanaChar = kanaDataMap[id] != null ? kanaDataMap[id]![script] : id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Practice ${currentIndex + 1} / ${allKana.length}'),
        backgroundColor: const Color(0xFFE1D5B9),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              script.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              kanaChar ?? '',
              style: const TextStyle(fontSize: 120, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            if (widget.difficulty == 'easy') ...[
              GridView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: () => _onOptionSelected(option),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _optionColor(option),
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: Colors.black26, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option.toUpperCase(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ] else if (widget.difficulty == 'hard') ...[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Type your answer',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                enabled: !answered,
                onSubmitted: (_) {
                  if (!answered) {
                    _onSubmitHardAnswer();
                  }
                },
              ),
              const SizedBox(height: 12),

              if (answered && correctAnswerSelected) ...[
                Column(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Correct!',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ] else if (answered && showCorrectAnswer) ...[
                Text(
                  'Correct answer: $id',
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),
              ],

              if (!answered)
                ElevatedButton(
                  onPressed: _onSubmitHardAnswer,
                  child: const Text('Submit'),
                ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: answered ? _nextQuestion : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBC002D),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
