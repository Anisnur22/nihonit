import 'package:flutter/material.dart';

import 'kana_grid_page.dart';
import 'practice_session_page.dart'; // Import your practice session page here

class KanaSelectionSummaryPage extends StatefulWidget {
  final List<String> selectedHiragana;
  final List<String> selectedKatakana;

  const KanaSelectionSummaryPage({
    super.key,
    required this.selectedHiragana,
    required this.selectedKatakana,
  });

  @override
  State<KanaSelectionSummaryPage> createState() => _KanaSelectionSummaryPageState();
}

class _KanaSelectionSummaryPageState extends State<KanaSelectionSummaryPage> {
  late List<String> hiraganaSelected;
  late List<String> katakanaSelected;

  String selectedDifficulty = ''; // no difficulty initially

  @override
  void initState() {
    super.initState();
    hiraganaSelected = List.from(widget.selectedHiragana);
    katakanaSelected = List.from(widget.selectedKatakana);
  }

  Future<void> _editKana(bool isKatakana) async {
    final result = await Navigator.pushReplacement<List<String>, dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => KanaGridPage(
          isKatakana: isKatakana,
          initialSelectedKana: isKatakana ? katakanaSelected : hiraganaSelected,
          otherScriptSelectedKana: isKatakana ? hiraganaSelected : katakanaSelected,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isKatakana) {
          katakanaSelected = result;
        } else {
          hiraganaSelected = result;
        }
      });
    }
  }

  Widget buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.black38, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDifficulty = 'easy';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedDifficulty == 'easy' ? const Color(0xFFBC002D) : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Easy',
                      style: TextStyle(
                        color: selectedDifficulty == 'easy' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDifficulty = 'hard';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedDifficulty == 'hard' ? const Color(0xFFBC002D) : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Hard',
                      style: TextStyle(
                        color: selectedDifficulty == 'hard' ? Colors.white : Colors.black87,
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
        const SizedBox(height: 16),
        Text(
          selectedDifficulty == 'easy'
              ? 'Multiple choice input'
              : selectedDifficulty == 'hard'
                  ? 'Keyboard input for reading'
                  : '',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int hiraganaCount = hiraganaSelected.length;
    final int katakanaCount = katakanaSelected.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, {
            'hiragana': hiraganaSelected,
            'katakana': katakanaSelected,
            'difficulty': selectedDifficulty,
          }),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    'Selected Kana',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1D5B9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1D5B9),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          children: [
                            InkWell(
                              onTap: () => _editKana(false),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: const Center(
                                  child: Text('Hiragana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _editKana(false),
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(8)),
                              child: Container(
                                color: const Color(0xFFD1C9B6),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text('$hiraganaCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1D5B9),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          children: [
                            InkWell(
                              onTap: () => _editKana(true),
                              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: const Center(
                                  child: Text('Katakana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _editKana(true),
                              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
                              child: Container(
                                color: const Color(0xFFD1C9B6),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text('$katakanaCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildDifficultySelector(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, top: 155),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 56,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove Hiragana',
                      onPressed: hiraganaCount > 0
                          ? () {
                              setState(() {
                                hiraganaSelected.clear();
                              });
                            }
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove Katakana',
                      onPressed: katakanaCount > 0
                          ? () {
                              setState(() {
                                katakanaSelected.clear();
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ElevatedButton(
          onPressed: (hiraganaCount + katakanaCount) > 0 && selectedDifficulty.isNotEmpty
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PracticeSessionPage(
                        selectedHiragana: hiraganaSelected,
                        selectedKatakana: katakanaSelected,
                        difficulty: selectedDifficulty,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: (hiraganaCount + katakanaCount) > 0 && selectedDifficulty.isNotEmpty
                ? const Color(0xFFBC002D)
                : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 131),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Practice', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
