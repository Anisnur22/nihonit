import 'package:coolapp/pages/practice/card_form_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class BrowseCardsPage extends StatefulWidget {
  final String deckId;

  const BrowseCardsPage({super.key, required this.deckId});

  @override
  State<BrowseCardsPage> createState() => _BrowseCardsPageState();
}

class _BrowseCardsPageState extends State<BrowseCardsPage> {
  bool _selectionMode = false;
  Set<String> _selectedCardIds = {};
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      _selectedCardIds.clear();
    });
  }

  void _onCardTap(String cardId) {
    if (!_selectionMode) return;

    setState(() {
      _selectedCardIds.contains(cardId)
          ? _selectedCardIds.remove(cardId)
          : _selectedCardIds.add(cardId);
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

  String formatDuration(Duration d) {
    if (d.inSeconds <= 0) return "✅ Now";
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return '${hours > 0 ? "${hours}h " : ""}${minutes}m ${seconds}s';
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
          IconButton(
            icon: Icon(_selectionMode ? Icons.close : Icons.delete),
            onPressed: _toggleSelectionMode,
            tooltip: _selectionMode ? 'Cancel' : 'Select to Delete',
          ),
          if (_selectionMode && _selectedCardIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedCards,
              tooltip: 'Delete Selected',
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cardsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading cards'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No cards yet.'));

          return StreamBuilder<int>(
            stream: _timerStream,
            builder: (context, timerSnapshot) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 12.0,
                      columns: const [
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('Front')),
                        DataColumn(label: Text('Back')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Due In')),
                      ],
                      rows: List<DataRow>.generate(docs.length, (index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;
                        final selected = _selectedCardIds.contains(id);
                        final timestamp = data['created_at'] as Timestamp?;
                        final dueAt = data['next_review'] as Timestamp?;
                        final formattedDate = timestamp != null
                            ? DateFormat('dd MMM yy').format(timestamp.toDate())
                            : 'N/A';

                        Duration countdown = dueAt != null
                            ? dueAt.toDate().difference(DateTime.now())
                            : Duration.zero;

                        return DataRow(
                          selected: _selectionMode && selected,
                          onSelectChanged: _selectionMode ? (_) => _onCardTap(id) : null,
                          color: MaterialStateProperty.resolveWith<Color?>((states) {
                            if (_selectionMode && selected) return Colors.grey[300];
                            return null;
                          }),
                          cells: [
                            DataCell(IgnorePointer(child: Text('${index + 1}'))),
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
                            DataCell(Text(formattedDate)),
                            DataCell(
                            SizedBox(
                              width: 80,
                              child: Text(
                                formatDuration(countdown),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: countdown.inSeconds <= 0 ? Colors.green : Colors.grey[700],
                                  fontWeight: countdown.inSeconds <= 0 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),

                          ],
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
