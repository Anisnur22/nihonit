import 'package:flutter/material.dart';

class TracingPage extends StatefulWidget {
  final String imageUrl;

  const TracingPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<TracingPage> createState() => _TracingPageState();
}

class _TracingPageState extends State<TracingPage> {
  bool showImage = true;
  bool showGrid = true;

  List<Offset?> points = [];

  void clearDrawing() {
    setState(() {
      points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFFE1D5B9),
  elevation: 0,
  toolbarHeight: kToolbarHeight, // default height, you can omit this if you want
  title: const SizedBox.shrink(), // empty widget, no title shown
  actions: [
    IconButton(
      icon: Icon(showImage ? Icons.image : Icons.image_not_supported),
      tooltip: showImage ? 'Hide Image' : 'Show Image',
      onPressed: () {
        setState(() {
          showImage = !showImage;
        });
      },
    ),
    IconButton(
      icon: Icon(showGrid ? Icons.grid_off : Icons.grid_on),
      tooltip: showGrid ? 'Hide Grid' : 'Show Grid',
      onPressed: () {
        setState(() {
          showGrid = !showGrid;
        });
      },
    ),
    IconButton(
      icon: const Icon(Icons.redo),
      tooltip: 'Clear Drawing',
      onPressed: clearDrawing,
    ),
  ],
),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // We'll display the image inside a container with fixed aspect ratio (like square)
          // You can adjust the aspect ratio as needed.
          final imageWidth = width;
          final imageHeight = width; // make it square for simplicity

          return Stack(
            children: [
              if (showImage)
                Positioned(
                  top: 0,
                  left: 0,
                  width: imageWidth,
                  height: imageHeight,
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.network(
                      widget.imageUrl,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Image not available'));
                      },
                    ),
                  ),
                ),

              if (showGrid)
                Positioned(
                  top: 0,
                  left: 0,
                  width: imageWidth,
                  height: imageHeight,
                  child: CustomPaint(
                    size: Size(imageWidth, imageHeight),
                    painter: GridPainter(columns: 2, rows: 2),
                  ),
                ),

              Positioned(
                top: 0,
                left: 0,
                width: imageWidth,
                height: imageHeight,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    RenderBox? box = context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      Offset point = box.globalToLocal(details.globalPosition);

                      // Restrict drawing inside image box
                      if (point.dx >= 0 &&
                          point.dx <= imageWidth &&
                          point.dy >= 0 &&
                          point.dy <= imageHeight) {
                        setState(() {
                          points = List.from(points)..add(point);
                        });
                      }
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      points = List.from(points)..add(null);
                    });
                  },
                  child: CustomPaint(
                    size: Size(imageWidth, imageHeight),
                    painter: DrawingPainter(points: points),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final int columns;
  final int rows;
  final Paint paintGrid;

  GridPainter({this.columns = 2, this.rows = 2})
      : paintGrid = Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // Draw vertical lines (columns - 1 lines)
    for (int i = 1; i < columns; i++) {
      double x = cellWidth * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }

    // Draw horizontal lines (rows - 1 lines)
    for (int j = 1; j < rows; j++) {
      double y = cellHeight * j;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Paint paintDrawing;

  DrawingPainter({required this.points})
      : paintDrawing = Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paintDrawing);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) =>
      oldDelegate.points != points;
}
