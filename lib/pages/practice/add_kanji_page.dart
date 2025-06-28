import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddKanjiPage extends StatefulWidget {
  final String deckId;

  const AddKanjiPage({required this.deckId, super.key});

  @override
  State<AddKanjiPage> createState() => _AddKanjiPageState();
}

class _AddKanjiPageState extends State<AddKanjiPage> {
  final Set<String> selectedKanjiIds = {};

  Future<void> addSelectedToDeck() async {
    final firestore = FirebaseFirestore.instance;
    final now = Timestamp.now();
    final snapshot = await firestore.collection('KanjiEntries').get();

    for (var doc in snapshot.docs) {
      if (selectedKanjiIds.contains(doc.id)) {
        final data = doc.data();
        final front = data['front'];
        final back = data['back'];

        await firestore
            .collection('practiceDecks')
            .doc(widget.deckId)
            .collection('cards')
            .add({
          'front': front,
          'back': back,
          'ease_factor': 2.5,
          'interval': 1,
          'repetition': 0,
          'last_review': now,
          'next_review': now,
          'created_at': now,
        });
      }
    }

    Navigator.pop(context);
  }

  Future<Set<String>> _getExistingFrontsInDeck() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .get();

    return snapshot.docs.map((doc) => doc['front'] as String).toSet();
  }

  Widget kanjiTable() {
    return FutureBuilder<Set<String>>(
      future: _getExistingFrontsInDeck(),
      builder: (context, deckSnapshot) {
        if (!deckSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final addedFronts = deckSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('KanjiEntries').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Select')),
                  DataColumn(label: Text('Front')),
                  DataColumn(label: Text('Back')),
                  DataColumn(label: Text('Status')),
                ],
                rows: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final front = data['front'] ?? '';
                  final back = data['back'] ?? '';
                  final selected = selectedKanjiIds.contains(doc.id);
                  final alreadyInDeck = addedFronts.contains(front);

                  return DataRow(
                    selected: selected,
                    cells: [
                      DataCell(Checkbox(
                        value: selected,
                        onChanged: (_) {
                          setState(() {
                            selected
                                ? selectedKanjiIds.remove(doc.id)
                                : selectedKanjiIds.add(doc.id);
                          });
                        },
                      )),
                      DataCell(Text(front)),
                      DataCell(Text(back)),
                      DataCell(Text(
                        alreadyInDeck ? '✓ In Deck' : 'New',
                        style: TextStyle(
                          color: alreadyInDeck ? Colors.green : Colors.black,
                          fontWeight: alreadyInDeck ? FontWeight.bold : FontWeight.normal,
                        ),
                      )),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 40),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Kanji',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
  padding: const EdgeInsets.only(bottom: 70),
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Note: After adding a card, tap the refresh icon to see it.',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      const Text(
        'Kanji List',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      kanjiTable(),
    ],
  ),
),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedKanjiIds.isEmpty ? null : addSelectedToDeck,
        label: const Text('Add to Deck'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
