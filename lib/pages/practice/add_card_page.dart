import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCardPage extends StatefulWidget {
  final String deckId;

  const AddCardPage({super.key, required this.deckId});


  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final TextEditingController frontController = TextEditingController();
  final TextEditingController backController = TextEditingController();

  void _handleAddCard() async {
  final frontText = frontController.text.trim();
  final backText = backController.text.trim();

  if (frontText.isNotEmpty && backText.isNotEmpty) {
    try {
      await FirebaseFirestore.instance
          .collection('practiceDecks')
          .doc(widget.deckId)
          .collection('cards')
          .add({
        'front': frontText,
        'back': backText,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in both fields')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFFE1D5B9),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: frontController,
              decoration: const InputDecoration(
                labelText: 'Front',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: backController,
              decoration: const InputDecoration(
                labelText: 'Back',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleAddCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
