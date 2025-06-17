import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StoryPage extends StatefulWidget {
  final String storyId;

  const StoryPage({super.key, required this.storyId});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late Future<DocumentSnapshot> _storyFuture;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _storyFuture = FirebaseFirestore.instance.collection('stories').doc(widget.storyId).get();
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _storyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final titleEn = data['title_en'] ?? '';
          final titleJp = data['title_jp'] ?? '';
          final imageUrl = data['image_url'] ?? '';
          final sentencesMap = data['sentences'] as Map<String, dynamic>? ?? {};

          // Sort sentences by 'order'
          final sortedSentences = sentencesMap.entries.toList()
            ..sort((a, b) {
              final aOrder = (a.value as Map)['order'] ?? 0;
              final bOrder = (b.value as Map)['order'] ?? 0;
              return aOrder.compareTo(bOrder);
            });

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(titleJp, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(titleEn, style: const TextStyle(fontSize: 22, color: Colors.grey)),
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.network(imageUrl),
                  ),

                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sortedSentences.length,
                  itemBuilder: (context, index) {
                    final sentenceData = sortedSentences[index].value as Map<String, dynamic>;
                    final textJp = sentenceData['text_jp'] ?? '';
                    final textEn = sentenceData['text_en'] ?? '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          title: Text(textJp, style: const TextStyle(fontSize: 18)),
                          subtitle: Text(textEn, style: const TextStyle(color: Colors.grey)),
                          trailing: IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await flutterTts.setLanguage("ja-JP");
                              await flutterTts.setPitch(1.0);
                              await flutterTts.setSpeechRate(0.2);
                              await flutterTts.speak(textJp);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
