import 'package:coolapp/pages/practice/card_form_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BrowseCardsPage extends StatefulWidget {
  final String deckId;

  const BrowseCardsPage({super.key, required this.deckId});

  @override
  State<BrowseCardsPage> createState() => _BrowseCardsPageState();
}

class _BrowseCardsPageState extends State<BrowseCardsPage> {
  bool _selectionMode = false;
  Set<String> _selectedCardIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedCardIds.clear();
    });
  }

  void _onCardTap(String cardId) {
    if (!_selectionMode) return;

    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }

  Future<void> _deleteSelectedCards() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Cards'),
        content: Text('Are you sure you want to delete ${_selectedCardIds.length} cards?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final cardId in _selectedCardIds) {
        final docRef = FirebaseFirestore.instance
            .collection('practiceDecks')
            .doc(widget.deckId)
            .collection('cards')
            .doc(cardId);
        batch.delete(docRef);
      }

      await batch.commit();
      setState(() {
        _selectionMode = false;
        _selectedCardIds.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsRef = FirebaseFirestore.instance
        .collection('practiceDecks')
        .doc(widget.deckId)
        .collection('cards')
        .orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode ? 'Select Cards' : 'Browse Cards'),
        backgroundColor: const Color(0xFFE1D5B9),
        actions: [
          if (_selectionMode && _selectedCardIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedCards,
              tooltip: 'Delete Selected',
            )
          else
            IconButton(
              icon: Icon(_selectionMode ? Icons.close : Icons.delete),
              onPressed: _toggleSelectionMode,
              tooltip: _selectionMode ? 'Cancel' : 'Select to Delete',
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

          if (docs.isEmpty) {
            return const Center(child: Text('No cards yet.'));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 16.0,
              headingRowHeight: 40.0,
              dataRowMinHeight: 40.0,
              dataRowMaxHeight: 60.0,
              columns: const [
                DataColumn(label: Text('No.')),
                DataColumn(label: Text('Front')),
                DataColumn(label: Text('Back')),
                DataColumn(label: Text('Date')),
              ],
              rows: List<DataRow>.generate(docs.length, (index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final id = doc.id;
                final selected = _selectedCardIds.contains(id);
                final timestamp = data['created_at'] as Timestamp?;
                final formattedDate = timestamp != null
                    ? DateFormat('dd MMM yy').format(timestamp.toDate())
                    : 'N/A';

                return DataRow(
  // Only show selected style when selection mode is ON
  selected: _selectionMode && selected,
  // Only enable checkbox click if in selection mode
  onSelectChanged: _selectionMode
      ? (_) => _onCardTap(id)
      : null,
  // Visually style selected rows only if in selection mode
  color: MaterialStateProperty.resolveWith<Color?>((states) {
    if (_selectionMode && selected) return Colors.grey[300];
    return null;
  }),
  // Make tapping a row go to Edit page ONLY if not in selection mode
  cells: [
    DataCell(
      IgnorePointer(
        child: Text('${index + 1}'),
      ),
    ),
    DataCell(
      GestureDetector(
        onTap: () {
          if (!_selectionMode) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardFormPage(
                  deckId: widget.deckId,
                  cardId: id,
                  initialFront: data['front'],
                  initialBack: data['back'],
                ),
              ),
            );
          }
        },
        child: SizedBox(
          width: 100,
          child: Text(data['front'] ?? '', softWrap: true),
        ),
      ),
    ),
    DataCell(
      GestureDetector(
        onTap: () {
          if (!_selectionMode) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardFormPage(
                  deckId: widget.deckId,
                  cardId: id,
                  initialFront: data['front'],
                  initialBack: data['back'],
                ),
              ),
            );
          }
        },
        child: SizedBox(
          width: 100,
          child: Text(data['back'] ?? '', softWrap: true),
        ),
      ),
    ),
    DataCell(
      GestureDetector(
        onTap: () {
          if (!_selectionMode) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CardFormPage(
                  deckId: widget.deckId,
                  cardId: id,
                  initialFront: data['front'],
                  initialBack: data['back'],
                ),
              ),
            );
          }
        },
        child: SizedBox(
          width: 90,
          child: Text(formattedDate),
        ),
      ),
    ),
  ],
);




              }),
            ),
          );
        },
      ),
    );
  }
}
