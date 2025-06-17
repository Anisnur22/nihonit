import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tracing_page.dart';

class KanaDetailPage extends StatefulWidget {
  final String kanaId;
  final bool isKatakana;

  const KanaDetailPage({
    super.key,
    required this.kanaId,
    required this.isKatakana,
  });

  @override
  State<KanaDetailPage> createState() => _KanaDetailPageState();
}

class _KanaDetailPageState extends State<KanaDetailPage> {
  final FlutterTts flutterTts = FlutterTts();

  Future<Map<String, dynamic>?> fetchKanaData(String kanaId) async {
    final doc = await FirebaseFirestore.instance
        .collection('hiraganaGujuon')
        .doc(kanaId.toLowerCase())
        .get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("ja-JP"); // Japanese
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.2);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black87),
            onPressed: () async {
              final data = await fetchKanaData(widget.kanaId);
              if (data != null) {
                final textToSpeak = widget.isKatakana
                    ? (data['katakana'] ?? '')
                    : (data['hiragana'] ?? '');
                if (textToSpeak.isNotEmpty) {
                  speak(textToSpeak);
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchKanaData(widget.kanaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data == null)
            return const Center(child: Text('No data found.'));

          final data = snapshot.data!;

          final imageUrl = widget.isKatakana
              ? (data['imageUrlKatakana'] ?? '')
              : (data['imageUrlHiragana'] ?? '');

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Big character depends on isKatakana
                Text(
                  widget.isKatakana
                      ? (data['katakana'] ?? '')
                      : (data['hiragana'] ?? ''),
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  data['pronunciation'] ?? '',
                  style: TextStyle(fontSize: 36, color: Colors.grey[800]),
                  textAlign: TextAlign.center,
                ),

                GestureDetector(
                onTap: () {
                  final targetIsKatakana = !widget.isKatakana;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KanaDetailPage(
                        kanaId: widget.kanaId,
                        isKatakana: targetIsKatakana,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        // 🔥 Removed underline here
                      ),
                      children: [
                        TextSpan(
                          text: widget.isKatakana ? 'Hiragana ' : 'Katakana ',
                        ),
                        WidgetSpan(
                          child: Icon(Icons.arrow_forward, size: 24, color: Colors.blue),
                        ),
                        TextSpan(
                          text: widget.isKatakana
                              ? ' ${data['hiragana'] ?? ''}'
                              : ' ${data['katakana'] ?? ''}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

                // New divider section
                const SizedBox(height: 32),
                Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align children to left
                children: [
                  Text(
                    'Stroke Order (Tap to Draw)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(thickness: 1.5),
                ],
              ),
                const SizedBox(height: 16),

                // Image section (clickable)
                if (imageUrl.isNotEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TracingPage(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: Image.network(
                        imageUrl,
                        height: 128,
                        width: 128,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Image not available');
                        },
                      ),
                    ),
                  )
                else
                  const Center(child: Text('No image available')),
              ],
            ),
          );
        },
      ),
    );
  }
}
