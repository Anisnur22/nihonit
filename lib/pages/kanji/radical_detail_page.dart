import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'radical_tracing_page.dart'; // Make sure this is your TracingPage

class RadicalDetailPage extends StatefulWidget {
  final String radicalId; // ID of the radical (e.g., "⼀")
  final String strokeType; // Stroke type - "1stroke" or "2stroke"

  const RadicalDetailPage({
    super.key,
    required this.radicalId,
    required this.strokeType,
  });

  @override
  State<RadicalDetailPage> createState() => _RadicalDetailPageState();
}

class _RadicalDetailPageState extends State<RadicalDetailPage> {
  Future<Map<String, dynamic>?> fetchRadicalData(String radicalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('radical')
          .doc(widget.strokeType)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey(radicalId)) {
          return data[radicalId]; // Return radical data
        }
      }
      return null;
    } catch (e) {
      print('Error fetching radical data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchRadicalData(widget.radicalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found.'));
          }

          final data = snapshot.data!;
          final imageUrl = data['strokeorder'] ?? '';
          final radical = widget.radicalId;
          final meaning = data['meaning'] ?? '';
          final pronunciation = data['pronunciation'] ?? '';
          final relatedKanji = data['relatedKanji'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radical character
                Text(
                  radical,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Meaning
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Meaning: $meaning',
                    style: TextStyle(fontSize: 24, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 20),

                // Pronunciation
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pronunciation: $pronunciation',
                    style: TextStyle(fontSize: 24, color: Colors.grey[800]),
                  ),
                ),
                const SizedBox(height: 20),

                // Related Kanji
                if (relatedKanji is List && relatedKanji.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Related Kanji: ${relatedKanji.join('、')}',
                      style: TextStyle(fontSize: 24, color: Colors.grey[800]),
                    ),
                  ),
                const SizedBox(height: 20),

                // Stroke Order Header
                const Text(
                  'Stroke Order (Tap to Draw)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Divider(thickness: 1.5),
                const SizedBox(height: 16),

                // Stroke order image (clickable)
                if (imageUrl.isNotEmpty)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TracingPage(
                              radicalId: widget.radicalId,
                              strokeType: widget.strokeType,
                              imageUrl: imageUrl,
                            ),
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
