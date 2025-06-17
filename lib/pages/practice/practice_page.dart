import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'deck_detail_page.dart';

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final user = FirebaseAuth.instance.currentUser;
  final Set<String> selectedDeckIds = {};
  bool selectionMode = false;

  void toggleSelection(String deckId) {
    setState(() {
      if (selectedDeckIds.contains(deckId)) {
        selectedDeckIds.remove(deckId);
      } else {
        selectedDeckIds.add(deckId);
      }
      selectionMode = selectedDeckIds.isNotEmpty;
    });
  }

  void clearSelection() {
    setState(() {
      selectedDeckIds.clear();
      selectionMode = false;
    });
  }

  Future<void> deleteSelectedDecks() async {
    for (final deckId in selectedDeckIds) {
      final deckRef = FirebaseFirestore.instance.collection('practiceDecks').doc(deckId);
      final cardsRef = deckRef.collection('cards');

      final cardSnapshots = await cardsRef.get();
      for (final card in cardSnapshots.docs) {
        await card.reference.delete();
      }

      await deckRef.delete();
    }

    clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in.')),
      );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () async {
              if (!selectionMode) {
                setState(() {
                  selectionMode = true;
                });
              } else if (selectedDeckIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No decks selected.")),
                );
              } else {
                final confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text("Delete selected decks?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await deleteSelectedDecks();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'PRACTICE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
              ),
              const SizedBox(height: 20),

              // 🔽 Deck List
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('practiceDecks')
                    .where('created_by', isEqualTo: user!.email)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No decks yet. Create one!"),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Column(
                    children: docs.map((doc) {
                      String deckId = doc.id;
                      String deckName = doc['name'];
                      final isSelected = selectedDeckIds.contains(deckId);

                      return GestureDetector(
                        onLongPress: () {
                          toggleSelection(deckId);
                        },
                        onTap: () {
                          if (selectionMode) {
                            toggleSelection(deckId);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeckDetailPage(
                                  deckId: deckId,
                                  deckName: deckName,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                          child: Container(
                            width: double.infinity,
                            height: 98,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.grey : const Color(0xFFBC002D),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                deckName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 42,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 30),

              // 🆕 Create Deck Button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final TextEditingController _deckNameController = TextEditingController();

                      return AlertDialog(
                        title: const Text('Name the Deck'),
                        content: TextField(
                          controller: _deckNameController,
                          maxLength: 12,
                          decoration: const InputDecoration(
                            hintText: 'Enter deck name (max 12 chars)',
                            counterText: "",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back'),
                          ),
                          TextButton(
                            onPressed: () async {
                              String deckName = _deckNameController.text.trim();
                              if (deckName.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Name can't be empty.")),
                                );
                              } else if (deckName.length > 12) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Name must be 12 characters or less.")),
                                );
                              } else {
                                await FirebaseFirestore.instance.collection('practiceDecks').add({
                                  'name': deckName,
                                  'created_by': user!.email!,
                                  'created_at': FieldValue.serverTimestamp(),
                                });
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF50C878),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                      child: Text(
                        'Create Practice Deck',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
