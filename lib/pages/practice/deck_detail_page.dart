import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_kana_page.dart';
import 'add_kanji_page.dart';
import 'browse_cards_page.dart';
import 'card_form_page.dart';

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
  bool _srsUpdating = false;

  Map<String, String> intervalLabels = {
    "Again": "1 min",
    "Hard": "3 min",
    "Good": "10 min",
    "Easy": "1 day",
  };

  Future<void> _onSRSPressed(String quality) async {
    setState(() {
      _srsUpdating = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .where('next_review', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('next_review')
        .get();

    final docs = snapshot.docs;
    if (_currentIndex >= docs.length) return;

    final doc = docs[_currentIndex];
    final card = doc.data() as Map<String, dynamic>;

    double ease = (card['ease_factor'] ?? 2.5).toDouble();
    int interval = (card['interval'] ?? 1).toInt();
    int reps = (card['repetition'] ?? 0).toInt();
    DateTime nextReview;

    switch (quality) {
      case "Again":
        reps = 0;
        interval = 0;
        ease -= 0.2;
        nextReview = DateTime.now().add(const Duration(minutes: 1));
        break;
      case "Hard":
        interval = 3;
        ease -= 0.15;
        reps++;
        nextReview = DateTime.now().add(const Duration(minutes: 3));
        break;
      case "Good":
        interval = 10;
        reps++;
        nextReview = DateTime.now().add(const Duration(minutes: 10));
        break;
      case "Easy":
        interval = 1440;
        ease += 0.1;
        reps++;
        nextReview = DateTime.now().add(const Duration(days: 1));
        break;
      default:
        return;
    }

    if (ease < 1.3) ease = 1.3;

    await doc.reference.update({
      'ease_factor': ease,
      'interval': interval,
      'repetition': reps,
      'last_review': Timestamp.now(),
      'next_review': Timestamp.fromDate(nextReview),
    });

    final newSnapshot = await FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .where('next_review', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('next_review')
        .get();

    setState(() {
      _currentIndex = 0;
      _showBack = false;
      _srsUpdating = false;
    });

    if (newSnapshot.docs.isEmpty) {
      setState(() {}); // rebuild to show “You’re done!”
    }
  }

  Widget _srsButton(String label, Color color, String intervalText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: () => _onSRSPressed(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(intervalText, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xFFE1D5B9);

    final now = Timestamp.now();
    final cardsRef = FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .where('next_review', isLessThanOrEqualTo: now)
        .orderBy('next_review');

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
                  if (value == 'add_card') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardFormPage(deckId: widget.deckId),
                      ),
                    );
                  } else if (value == 'add_kana') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddKanaPage(deckId: widget.deckId),
                      ),
                    );
                  } else if (value == 'add_kanji') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddKanjiPage(deckId: widget.deckId),
                      ),
                    );
                  }
                },
                offset: const Offset(0, 40),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'add_card', child: Text('Add Card')),
                  PopupMenuItem(value: 'add_kana', child: Text('Add Kana')),
                  PopupMenuItem(value: 'add_kanji', child: Text('Add Kanji')),
                ],
                child: const Text(
                  'Add',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                ),
              ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
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

          if (docs.isEmpty || _currentIndex >= docs.length) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Text(
                    'Note: Tap the refresh icon to check if any cards are due.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'You\'re done!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          }

          final currentDoc = docs[_currentIndex];
          final currentCard = currentDoc.data() as Map<String, dynamic>;
          final front = currentCard['front'] ?? '';
          final back = currentCard['back'] ?? '';

          return GestureDetector(
            onTap: () {
              if (!_srsUpdating) {
                setState(() {
                  _showBack = !_showBack;
                });
              }
            },
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardFormPage(
                    deckId: widget.deckId,
                    cardId: currentDoc.id,
                    initialFront: front,
                    initialBack: back,
                  ),
                ),
              );
            },
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
                      if (_showBack && !_srsUpdating) ...[
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
                            _srsButton("Again", Colors.redAccent, intervalLabels["Again"]!),
                            _srsButton("Hard", Colors.orange, intervalLabels["Hard"]!),
                            _srsButton("Good", Colors.green, intervalLabels["Good"]!),
                            _srsButton("Easy", Colors.blue, intervalLabels["Easy"]!),
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
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFFE1D5B9),
                    child: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardFormPage(
                            deckId: widget.deckId,
                            cardId: currentDoc.id,
                            initialFront: front,
                            initialBack: back,
                          ),
                        ),
                      );
                    },
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
