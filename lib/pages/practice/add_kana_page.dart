import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddKanaPage extends StatefulWidget {
  final String deckId;

  const AddKanaPage({required this.deckId, super.key});

  @override
  State<AddKanaPage> createState() => _AddKanaPageState();
}

class _AddKanaPageState extends State<AddKanaPage> {
  final Set<String> selectedKana = {};
  String selectedType = 'hiragana';

  Future<void> addSelectedToDeck() async {
    final firestore = FirebaseFirestore.instance;
    final docs = await firestore.collection('hiraganaGujuon').get();
    final now = Timestamp.now();

    for (var doc in docs.docs) {
      final data = doc.data();
      final hiragana = data['hiragana'];
      final katakana = data['katakana'];
      final pronunciation = data['pronunciation'];

      Future<void> addCard(String kana) async {
        if (selectedKana.contains(kana)) {
          await firestore
              .collection('practiceDecks')
              .doc(widget.deckId)
              .collection('cards')
              .add({
            'front': kana,
            'back': pronunciation,
            'ease_factor': 2.5,
            'interval': 1,
            'repetition': 0,
            'last_review': now,
            'next_review': now,
            'created_at': now,
          });
        }
      }

      await addCard(hiragana);
      await addCard(katakana);
    }

    Navigator.pop(context);
  }

  Widget kanaTable(String type) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('practiceDecks')
          .doc(widget.deckId)
          .collection('cards')
          .get(),
      builder: (context, addedSnapshot) {
        if (!addedSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final addedFronts = addedSnapshot.data!.docs
            .map((doc) => doc['front'] as String)
            .toSet();

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('hiraganaGujuon').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.docs;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Select')),
                  DataColumn(label: Text('Front')),
                  DataColumn(label: Text('Back')),
                  DataColumn(label: Text('Status')),
                ],
                rows: data.map((doc) {
                  final kana = doc[type];
                  final pronunciation = doc['pronunciation'];
                  final selected = selectedKana.contains(kana);
                  final alreadyAdded = addedFronts.contains(kana);

                  return DataRow(
                    selected: selected,
                    cells: [
                      DataCell(Checkbox(
                        value: selected,
                        onChanged: (_) {
                          setState(() {
                            selected
                                ? selectedKana.remove(kana)
                                : selectedKana.add(kana);
                          });
                        },
                      )),
                      DataCell(Text(kana)),
                      DataCell(Text(pronunciation)),
                      DataCell(Text(
                        alreadyAdded ? '✓ In Deck' : 'New',
                        style: TextStyle(
                          color: alreadyAdded ? Colors.green : Colors.black,
                          fontWeight:
                              alreadyAdded ? FontWeight.bold : FontWeight.normal,
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
          'Add Kana',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Kana Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: const [
                DropdownMenuItem(value: 'hiragana', child: Text('Hiragana')),
                DropdownMenuItem(value: 'katakana', child: Text('Katakana')),
              ],
            ),
            const SizedBox(height: 10),
            kanaTable(selectedType),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedKana.isEmpty ? null : addSelectedToDeck,
        label: const Text('Add to Deck'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
