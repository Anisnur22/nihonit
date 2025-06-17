import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainMenuPage extends StatefulWidget {
  final String title;
  final bool showLeaderboard;
  final Widget Function(Function(String scriptType, String? kanjiMode)) settingsBuilder;
  final void Function(String scriptType, String? kanjiMode) onPlayCallback;

  const MainMenuPage({
    super.key,
    required this.title,
    required this.showLeaderboard,
    required this.settingsBuilder,
    required this.onPlayCallback,
  });

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  List<Map<String, dynamic>> topPlayers = [];
  bool isLoading = true;

  // Settings selected by the user
  String selectedScriptType = 'hiragana';
  String? selectedKanjiMode;

  @override
  void initState() {
    super.initState();
    if (widget.showLeaderboard) {
      fetchLeaderboard();
    }
  }

  Future<void> fetchLeaderboard() async {
  setState(() {
    isLoading = true;
  });

  final firestore = FirebaseFirestore.instance;
  final usersSnapshot = await firestore.collection('users').get();

  List<Map<String, dynamic>> scores = [];

  for (final userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    final userData = userDoc.data();

    final username = userData.containsKey('username') && userData['username'] != null
        ? userData['username']
        : userId;

    // Fetch one score document based on current selectedScriptType
    final gameStatDoc = await firestore
        .collection('users')
        .doc(userId)
        .collection('gamestats')
        .doc(selectedScriptType)
        .get();

    if (gameStatDoc.exists) {
      final data = gameStatDoc.data();
      final score = data?['score'] ?? 0;

      scores.add({
        'username': username,
        'score': score,
      });
    }
  }

  scores.sort((a, b) => b['score'].compareTo(a['score']));

  setState(() {
    topPlayers = scores;
    isLoading = false;
  });
}


  void onSettingsChanged(String scriptType, String? kanjiMode) {
    setState(() {
      selectedScriptType = scriptType;
      selectedKanjiMode = kanjiMode;
    });

    if (widget.showLeaderboard) {
      fetchLeaderboard(); // Refresh leaderboard on script change
    }
  }

  String _getScriptLabel(String key) {
    switch (key) {
      case 'hiragana':
        return 'Hiragana';
      case 'katakana':
        return 'Katakana';
      case 'kanji':
        return 'Kanji';
      case 'all':
        return 'All';
      default:
        return 'Players';
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF9F5EF),
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 40),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(widget.title, style: const TextStyle(fontSize: 28)),
      centerTitle: true,
      backgroundColor: const Color(0xFFE1D5B9),
    ),

    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Script settings UI
          widget.settingsBuilder(onSettingsChanged),

          const SizedBox(height: 20),

          if (widget.showLeaderboard) ...[
            Text(
              "🌟 Top ${_getScriptLabel(selectedScriptType)} Players 🌟",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 180),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : topPlayers.isEmpty
                      ? const Center(child: Text("No scores yet."))
                      : ListView.builder(
                          itemCount: topPlayers.length,
                          itemBuilder: (context, index) {
                            final player = topPlayers[index];
                            final emoji = switch (index) {
                              0 => "🥇",
                              1 => "🥈",
                              2 => "🥉",
                              _ => "🎮"
                            };

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                                title: Text(player['username'],
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                trailing: Text("⭐ ${player['score']}",
                                    style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 30),
          ],

          // Play Button
          ElevatedButton(
            onPressed: () {
              widget.onPlayCallback(selectedScriptType, selectedKanjiMode);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFDEB887),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            child: const Text("Play", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    ),
  );
}

}
