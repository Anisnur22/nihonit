import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'radical_tracing_page.dart'; // Assuming this is where the stroke order drawing happens

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

  // Adjust the query to get the correct radical data based on stroke type
  Future<Map<String, dynamic>?> fetchRadicalData(String radicalId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('radical') // Radical collection
          .doc(widget.strokeType) // "1stroke" or "2stroke"
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if the radical field exists
        if (data.containsKey(radicalId)) {
          return data[radicalId]; // Return the entire data of the radical (e.g., meaning, pronunciation, strokeorder)
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
        title: null, // Remove the title from the AppBar
        leading: IconButton(  // Place the back button in the leading section
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),  // Same size as RadicalGridPage
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,  // Optionally set elevation to 0 for a flat look
      ),
      body: FutureBuilder<Map<String, dynamic>?>( 
        future: fetchRadicalData(widget.radicalId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data == null)
            return const Center(child: Text('No data found.'));

          final data = snapshot.data!;
          final imageUrl = data['strokeorder'] ?? ''; // URL for stroke order image
          final radical = widget.radicalId; // Radical character (e.g., "⼀")
          final meaning = data['meaning'] ?? ''; // Meaning of the radical
          final pronunciation = data['pronunciation'] ?? ''; // Pronunciation info

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Radical character - Display at the top with large and bold text
                Text(
                  radical,  // Show the radical character (e.g., "⼀")
                  style: const TextStyle(
                    fontSize: 120,  // Big font size
                    fontWeight: FontWeight.bold,  // Bold font weight
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Meaning (aligned left, smaller font size)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Meaning: $meaning',
                    style: TextStyle(fontSize: 24, color: Colors.grey[800]), // Smaller font size
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                // Pronunciation (aligned left, smaller font size)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pronunciation: $pronunciation',
                    style: TextStyle(fontSize: 24, color: Colors.grey[800]), // Smaller font size
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 20),
                // Stroke Order Section
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
                // Image section (clickable)
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
                              imageUrl: imageUrl, // Pass imageUrl to TracingPage
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

