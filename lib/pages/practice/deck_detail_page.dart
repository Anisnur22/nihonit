import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'browse_cards_page.dart';
import 'add_card_page.dart';

class DeckDetailPage extends StatefulWidget {
  final String deckId;
  final String deckName;

  const DeckDetailPage({
    required this.deckId,
    required this.deckName,
    super.key,
  });

  @override
  State<DeckDetailPage> createState() => _DeckDetailPageState();
}

class _DeckDetailPageState extends State<DeckDetailPage> {
  int _currentIndex = 0;
  bool _showBack = false;

  void _nextCard(int totalCards) {
  setState(() {
    if (_currentIndex >= totalCards - 1) {
      _currentIndex = 0;
    } else {
      _currentIndex++;
    }
    _showBack = false;
  });
}


  void _onSRSPressed(String quality) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .orderBy('created_at')
        .get();

    final docs = snapshot.docs;

    if (_currentIndex >= docs.length) return;

    final doc = docs[_currentIndex];
    final card = doc.data() as Map<String, dynamic>;

    double ease = (card['ease_factor'] ?? 2.5).toDouble();
    int interval = (card['interval'] ?? 1).toInt();
    int reps = (card['repetition'] ?? 0).toInt();

    switch (quality) {
      case "Again":
        reps = 0;
        interval = 1;
        ease = ease - 0.2;
        break;
      case "Hard":
        interval = (interval * 1.2).round();
        ease = ease - 0.15;
        reps++;
        break;
      case "Good":
        interval = (interval * ease).round();
        reps++;
        break;
      case "Easy":
        interval = (interval * (ease + 0.15)).round();
        ease = ease + 0.1;
        reps++;
        break;
    }

    if (ease < 1.3) ease = 1.3;

    final nextReview = DateTime.now().add(Duration(days: interval));

    await doc.reference.update({
      'ease_factor': ease,
      'interval': interval,
      'repetition': reps,
      'last_review': Timestamp.now(),
      'next_review': Timestamp.fromDate(nextReview),
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _nextCard(docs.length);
    });
  }

  Widget _srsButton(String label, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () => _onSRSPressed(label),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFFE1D5B9);

    final cardsRef = FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .orderBy('created_at');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 40),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: const PopupMenuThemeData(
                  color: appBarColor,
                  textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'card') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCardPage(deckId: widget.deckId),
                      ),
                    );
                  }
                },
                offset: const Offset(0, 40),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'card', child: Text('Add Card')),
                ],
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: implement edit deck
              },
              child: const Text('Edit', style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrowseCardsPage(deckId: widget.deckId),
                  ),
                );
              },
              child: const Text('Browse', style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cardsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cards'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.only(top: 40),
      child: Text(
        'You\'re done for now!',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
  );
}


          if (_currentIndex >= docs.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'You\'re done!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }

          final currentCard = docs[_currentIndex].data() as Map<String, dynamic>;
          final front = currentCard['front'] ?? '';
          final back = currentCard['back'] ?? '';

          return GestureDetector(
            onTap: () {
              setState(() {
                _showBack = !_showBack;
              });
            },
            onDoubleTap: () => _nextCard(docs.length),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        front,
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (_showBack) ...[
                        const SizedBox(height: 20),
                        const Divider(thickness: 2, indent: 40, endIndent: 40, color: Colors.grey),
                        const SizedBox(height: 20),
                        Text(
                          back,
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _srsButton("Again", Colors.redAccent),
                            _srsButton("Hard", Colors.orange),
                            _srsButton("Good", Colors.green),
                            _srsButton("Easy", Colors.blue),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        "Tap to reveal",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      Positioned(
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${docs.length}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
