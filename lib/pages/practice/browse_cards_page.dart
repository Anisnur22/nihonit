import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting timestamp

class BrowseCardsPage extends StatelessWidget {
  final String deckId;

  const BrowseCardsPage({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final cardsRef = FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(deckId)
        .collection('cards')
        .orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cards'),
        backgroundColor: const Color(0xFFE1D5B9),
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
            return const Center(child: Text('No cards yet.'));
          }

          return SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
    columnSpacing: 16.0, // Reduce space between columns
    headingRowHeight: 40.0, // Smaller header
    dataRowMinHeight: 40.0,
    dataRowMaxHeight: 60.0,
    columns: const [
      DataColumn(label: Text('No.')),
      DataColumn(label: Text('Front')),
      DataColumn(label: Text('Back')),
      DataColumn(label: Text('Date')),
    ],
    rows: List<DataRow>.generate(docs.length, (index) {
      final data = docs[index].data() as Map<String, dynamic>;
      final Timestamp? timestamp = data['created_at'];
      final String formattedDate = timestamp != null
          ? DateFormat('dd MMM yy').format(timestamp.toDate()) // shorter format
          : 'N/A';

      return DataRow(cells: [
        DataCell(Text('${index + 1}')),
        DataCell(SizedBox(width: 100, child: Text(data['front'] ?? '', softWrap: true))),
        DataCell(SizedBox(width: 100, child: Text(data['back'] ?? '', softWrap: true))),
        DataCell(SizedBox(width: 90, child: Text(formattedDate))),
      ]);
    }),
  ),
);

        },
      ),
    );
  }
}
