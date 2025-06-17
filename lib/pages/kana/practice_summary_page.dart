import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class PracticeSummaryPage extends StatefulWidget {
  final Map<String, Map<String, int>> practiceResults;
  final int totalSelectedCards;  // total number of cards selected
  final List<String> selectedCards;  // list of all selected card ids

  const PracticeSummaryPage({
    Key? key,
    required this.practiceResults,
    required this.totalSelectedCards,
    required this.selectedCards,
  }) : super(key: key);

  @override
  _PracticeSummaryPageState createState() => _PracticeSummaryPageState();
}

class _PracticeSummaryPageState extends State<PracticeSummaryPage> {
  late ConfettiController _confettiController;
  bool allCorrect = false;

  @override
void initState() {
  super.initState();

  allCorrect = widget.practiceResults.entries.every((entry) {
    final stats = entry.value;
    final failCount = (stats['hiraganaFail'] ?? 0) + (stats['katakanaFail'] ?? 0);
    return failCount == 0;
  });

  _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  if (allCorrect) {
    _confettiController.play();
  }
}

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalPass = 0;
    int totalFail = 0;

    widget.practiceResults.forEach((_, stats) {
      totalPass += (stats['hiraganaPass'] ?? 0) + (stats['katakanaPass'] ?? 0);
      totalFail += (stats['hiraganaFail'] ?? 0) + (stats['katakanaFail'] ?? 0);
    });

    final totalCards = widget.totalSelectedCards;
    final totalAnswers = totalPass + totalFail;
    final percentCorrect = totalAnswers == 0 ? 0 : (totalPass / totalAnswers * 100).round();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Quiz Complete!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: totalPass.toDouble(),
                                  title: '',
                                  radius: 60,
                                ),
                                PieChartSectionData(
                                  color: Colors.red,
                                  value: totalFail.toDouble(),
                                  title: '',
                                  radius: 60,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$percentCorrect%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Text(
                                'Correct',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalPass / $totalCards',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Right ', style: TextStyle(fontSize: 16)),
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              const SizedBox(width: 4),
                              Text('$totalPass', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Wrong ', style: TextStyle(fontSize: 16)),
                              const Icon(Icons.cancel, color: Colors.red, size: 20),
                              const SizedBox(width: 4),
                              Text('$totalFail', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Results',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: widget.selectedCards.map((character) {
                      final stats = widget.practiceResults[character] ?? {
                        'hiraganaPass': 0,
                        'hiraganaFail': 0,
                        'katakanaPass': 0,
                        'katakanaFail': 0,
                      };

                      final passCount = (stats['hiraganaPass'] ?? 0) + (stats['katakanaPass'] ?? 0);
                      final failCount = (stats['hiraganaFail'] ?? 0) + (stats['katakanaFail'] ?? 0);

                      final passed = failCount == 0 && passCount > 0;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1D5B9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Text(
                            character.toUpperCase(),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            passed ? Icons.check_circle : Icons.cancel,
                            color: passed ? Colors.green : Colors.red,
                            size: 32,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          if (allCorrect)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: drawStar,
              ),
            ),
        ],
      ),
    );
  }
}

Path drawStar(Size size) {
  final path = Path();
  final numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = 360 / numberOfPoints;
  final halfDegreesPerStep = degreesPerStep / 2;
  path.moveTo(size.width, halfWidth);

  for (int step = 1; step <= numberOfPoints; step++) {
    final double x = halfWidth + externalRadius * math.cos(step * degreesPerStep * math.pi / 180);
    final double y = halfWidth + externalRadius * math.sin(step * degreesPerStep * math.pi / 180);
    path.lineTo(x, y);
    final double x2 = halfWidth + internalRadius * math.cos(step * degreesPerStep * math.pi / 180 - halfDegreesPerStep * math.pi / 180);
    final double y2 = halfWidth + internalRadius * math.sin(step * degreesPerStep * math.pi / 180 - halfDegreesPerStep * math.pi / 180);
    path.lineTo(x2, y2);
  }
  path.close();
  return path;
}
