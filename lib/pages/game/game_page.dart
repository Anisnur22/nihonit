import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_menu.dart';
import 'raindrop_game_page.dart';
import 'raindrop_settings.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  Future<List<GameModel>> fetchGames() async {
    final snapshot = await FirebaseFirestore.instance.collection('games').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return GameModel.fromMap(data);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'GAME',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<GameModel>>(
              future: fetchGames(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No games found'));
                }

                final games = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GameTile(
                          name: game.name,
                          description: game.description,
                          imageUrl: game.imageUrl,
                          onTap: () {
                            _handleGameTap(context, game);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleGameTap(BuildContext context, GameModel game) {
    final gameRoutes = <String, void Function()>{
      'raindrop': () {
        String selectedScriptType = 'hiragana';
        String? selectedKanjiMode;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainMenuPage(
              title: "Raindrop Quiz",
              showLeaderboard: true,
              settingsBuilder: (onSettingsChanged) {
                return RaindropSettings(
                  onSettingsChanged: (scriptType, kanjiMode) {
                    selectedScriptType = scriptType;
                    selectedKanjiMode = kanjiMode;
                    onSettingsChanged(scriptType, kanjiMode);
                  },
                );
              },
              onPlayCallback: (scriptType, kanjiMode) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RaindropGamePage(
                      scriptType: scriptType,
                      kanjiMode: kanjiMode,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    };

    if (gameRoutes.containsKey(game.route)) {
      gameRoutes[game.route]!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game "${game.name}" not yet implemented.')),
      );
    }
  }
}

// Game model class
class GameModel {
  final String name;
  final String description;
  final String imageUrl;
  final String route;

  GameModel({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.route,
  });

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      name: map['name'] ?? 'No name',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      route: map['route'] ?? '',
    );
  }
}

// Game tile widget
class GameTile extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const GameTile({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(child: Text("No image")),
                      ),
              ),

              // Description bar (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  color: const Color(0xFFE1D5B9),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Game name (above the bar)
              Positioned(
                bottom: 58,
                left: 10,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
