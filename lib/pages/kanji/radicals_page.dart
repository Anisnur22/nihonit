import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'radical_detail_page.dart'; // Assuming you have a detailed page for each radical

class RadicalGridPage extends StatefulWidget {
  const RadicalGridPage({super.key});

  @override
  _RadicalGridPageState createState() => _RadicalGridPageState();
}

class _RadicalGridPageState extends State<RadicalGridPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> radicals1Stroke = {}; // 1 Stroke radicals
  Map<String, dynamic> radicals2Stroke = {}; // 2 Strokes radicals

  @override
  void initState() {
    super.initState();
    fetchRadicalData();
  }

  Future<void> fetchRadicalData() async {
    try {
      // Fetch 1 Stroke radicals
      DocumentSnapshot snapshot1 = await _firestore.collection('radical').doc('1stroke').get();
      Map<String, dynamic> radicals1 = snapshot1.data() as Map<String, dynamic>;

      // Fetch 2 Stroke radicals
      DocumentSnapshot snapshot2 = await _firestore.collection('radical').doc('2stroke').get();
      Map<String, dynamic> radicals2 = snapshot2.data() as Map<String, dynamic>;

      setState(() {
        radicals1Stroke = radicals1;
        radicals2Stroke = radicals2;
      });
    } catch (e) {
      print("Error fetching radicals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE1D5B9),
        title: null, // Remove the title from the AppBar
        leading: IconButton(  // Place the back button in the leading section
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: radicals1Stroke.isEmpty || radicals2Stroke.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(  // Wrap the entire body with a SingleChildScrollView
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // RADICALS title
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'RADICALS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                        ),
                      ),
                    ),
                  ),
                  // 1 Stroke Divider
                  Container(
                    color: const Color(0xFFE1D5B9),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: const Center(
                      child: Text(
                        '1 Stroke',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // 1 Stroke Radicals (Display buttons in 5 columns)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling within GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 5 columns
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: radicals1Stroke.keys.length,
                      itemBuilder: (context, index) {
                        final key = radicals1Stroke.keys.elementAt(index);
                        return RadicalButton(
                          radical: key,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RadicalDetailPage(
                                  radicalId: key,
                                  strokeType: '1stroke', // Pass strokeType here
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // 2 Stroke Divider
                  Container(
                    color: const Color(0xFFE1D5B9),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: const Center(
                      child: Text(
                        '2 Strokes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  // 2 Stroke Radicals (Display buttons in 5 columns)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling within GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 5 columns
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: radicals2Stroke.keys.length,
                      itemBuilder: (context, index) {
                        final key = radicals2Stroke.keys.elementAt(index);
                        return RadicalButton(
                          radical: key,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RadicalDetailPage(
                                  radicalId: key,
                                  strokeType: '2stroke', // Pass strokeType here
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
            ),
    );
  }
}

class RadicalButton extends StatelessWidget {
  final String radical;
  final VoidCallback onTap;

  const RadicalButton({
    super.key,
    required this.radical,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 2, // Ensures the height and width are equal (square shape)
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFBC002D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              radical, // Only show the radical name
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
