import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'kana_selection.dart';
import 'kanadetail_page.dart';


class KanaGridPage extends StatefulWidget {
  final bool isKatakana;
  final List<String>? initialSelectedKana;
  final List<String>? otherScriptSelectedKana;

  const KanaGridPage({
    super.key,
    required this.isKatakana,
    this.initialSelectedKana,
    this.otherScriptSelectedKana,
  });

  @override
  _KanaGridPageState createState() => _KanaGridPageState();
}

class _KanaGridPageState extends State<KanaGridPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSelecting = false;
  List<String> selectedKana = [];
  Map<String, dynamic> kanaMap = {};

  final List<String> vowels = ['a', 'i', 'u', 'e', 'o'];
  final List<List<String>> gojuonOrder = [
    ['a', 'i', 'u', 'e', 'o'],
    ['ka', 'ki', 'ku', 'ke', 'ko'],
    ['sa', 'shi', 'su', 'se', 'so'],
    ['ta', 'chi', 'tsu', 'te', 'to'],
    ['na', 'ni', 'nu', 'ne', 'no'],
    ['ha', 'hi', 'fu', 'he', 'ho'],
    ['ma', 'mi', 'mu', 'me', 'mo'],
    ['ya', '', 'yu', '', 'yo'],
    ['ra', 'ri', 'ru', 're', 'ro'],
    ['wa', '', '', '', 'wo'],
    ['n', '', '', '', ''],
  ];

  String get collectionName => 'hiraganaGujuon';

  @override
  void initState() {
    super.initState();
    fetchKanaData();

    if (widget.initialSelectedKana != null && widget.initialSelectedKana!.isNotEmpty) {
      _isSelecting = true;
      selectedKana = List.from(widget.initialSelectedKana!);
    }
  }

  Future<void> fetchKanaData() async {
    QuerySnapshot snapshot = await _firestore.collection(collectionName).get();
    final data = <String, dynamic>{};

    for (var doc in snapshot.docs) {
      final id = doc.id.toLowerCase();
      final kana = doc.data() as Map<String, dynamic>;

      final key = widget.isKatakana ? 'katakana' : 'hiragana';
      if (kana.containsKey(key) && kana.containsKey('pronunciation')) {
        data[id] = {
          key: kana[key],
          'pronunciation': kana['pronunciation'],
        };
      }
    }

    setState(() {
      kanaMap = data;
    });
  }

  void enterSelectionMode() {
    setState(() {
      _isSelecting = true;
      selectedKana.clear();
    });
  }

  void exitSelectionMode() {
    setState(() {
      _isSelecting = false;
      selectedKana.clear();
    });
  }

  void toggleSelection(String kana) {
    setState(() {
      if (selectedKana.contains(kana)) {
        selectedKana.remove(kana);
      } else {
        selectedKana.add(kana);
      }
    });
  }

  void selectAll() {
    final allKana = <String>[];
    for (var row in gojuonOrder) {
      for (var k in row) {
        if (k.isNotEmpty) allKana.add(k);
      }
    }
    setState(() {
      selectedKana = allKana;
    });
  }

  void resetSelection() {
    setState(() {
      selectedKana.clear();
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, selectedKana);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isKatakana ? 'KATAKANA' : 'HIRAGANA';
    final key = widget.isKatakana ? 'katakana' : 'hiragana';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFE1D5B9),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
            onPressed: () => _onWillPop(),
          ),
          actions: _isSelecting
              ? [
                  TextButton(
                    onPressed: selectAll,
                    child: const Text(
                      'Select All',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: resetSelection,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 28),
                    onPressed: exitSelectionMode,
                    tooltip: 'Exit selection mode',
                  ),
                ]
              : [
                  GestureDetector(
                    onTap: enterSelectionMode,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        'Select',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
        ),
        body: kanaMap.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      color: const Color(0xFFE1D5B9),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: const Center(
                        child: Text(
                          'Basic',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              Container(),
                              for (var vowel in vowels)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      vowel.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          for (int i = 0; i < gojuonOrder.length; i++)
                            TableRow(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      i == 0
                                          ? ''
                                          : gojuonOrder[i][0].isNotEmpty
                                              ? gojuonOrder[i][0][0].toUpperCase()
                                              : '',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                for (var kana in gojuonOrder[i])
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: kana.isEmpty
                                        ? const SizedBox.shrink()
                                        : GestureDetector(
                                            onTap: () {
                                              if (_isSelecting) {
                                                toggleSelection(kana);
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => KanaDetailPage(
                                                      kanaId: kana,
                                                      isKatakana: widget.isKatakana,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: _isSelecting && selectedKana.contains(kana)
                                                    ? Colors.green
                                                    : const Color(0xFFBC002D),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: kanaMap.containsKey(kana)
                                                    ? Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            kanaMap[kana][key] ?? '',
                                                            style: const TextStyle(
                                                              fontSize: 24,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            kanaMap[kana]['pronunciation'] ?? '',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const Text(
                                                        '?',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: selectedKana.isNotEmpty
            ? () async {
                final result = await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KanaSelectionSummaryPage(
                      selectedHiragana: widget.isKatakana ? (widget.otherScriptSelectedKana ?? []) : selectedKana,
                      selectedKatakana: widget.isKatakana ? selectedKana : (widget.otherScriptSelectedKana ?? []),
                    ),
                  ),
                );

                if (result is Map<String, List<String>>) {
                  setState(() {
                    if (widget.isKatakana) {
                      selectedKana = result['katakana'] ?? selectedKana;
                    } else {
                      selectedKana = result['hiragana'] ?? selectedKana;
                    }
                  });
                }
              }
            : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedKana.isNotEmpty ? const Color(0xFFBC002D) : Colors.grey,
              foregroundColor: selectedKana.isNotEmpty ? Colors.white : Colors.black38,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Practice',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
