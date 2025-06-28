import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardFormPage extends StatefulWidget {
  final String deckId;
  final String? cardId; // null = add mode
  final String? initialFront;
  final String? initialBack;

  const CardFormPage({
    super.key,
    required this.deckId,
    this.cardId,
    this.initialFront,
    this.initialBack,
  });

  @override
  State<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends State<CardFormPage> {
  late TextEditingController _frontController;
  late TextEditingController _backController;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.initialFront ?? '');
    _backController = TextEditingController(text: widget.initialBack ?? '');
  }

  Future<void> _saveCard() async {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    if (front.isEmpty || back.isEmpty) return;

    final cardRef = FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards');

    if (widget.cardId == null) {
      // Add mode
      await cardRef.add({
        'front': front,
        'back': back,
        'ease_factor': 2.5,
        'interval': 1,
        'repetition': 0,
        'last_review': Timestamp.now(),
        'next_review': Timestamp.now(),
        'created_at': Timestamp.now(),
      });
    } else {
      // Edit mode
      await cardRef.doc(widget.cardId).update({
        'front': front,
        'back': back,
      });
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cardId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        elevation: 0,
        toolbarHeight: 80,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 40),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Card' : 'Add Card',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text(
          'Note: After adding a card, tap the refresh icon to see it.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      TextField(
        controller: _frontController,
        decoration: const InputDecoration(labelText: 'Front'),
      ),
      TextField(
        controller: _backController,
        decoration: const InputDecoration(labelText: 'Back'),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              final temp = _frontController.text;
              setState(() {
                _frontController.text = _backController.text;
                _backController.text = temp;
              });
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Swap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.black,
            ),
          ),
          ElevatedButton(
            onPressed: _saveCard,
            child: Text(isEditing ? 'Save Changes' : 'Add Card'),
          ),
        ],
      ),
    ],
  ),
),


    );
  }
}
