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
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(showImage ? Icons.image : Icons.image_not_supported),
            tooltip: showImage ? 'Hide Image' : 'Show Image',
            onPressed: () => setState(() => showImage = !showImage),
          ),
          IconButton(
            icon: Icon(showGrid ? Icons.grid_off : Icons.grid_on),
            tooltip: showGrid ? 'Hide Grid' : 'Show Grid',
            onPressed: () => setState(() => showGrid = !showGrid),
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
          final size = constraints.biggest;
          final canvasSize = size.shortestSide * 0.95;

          return Center(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: canvasSize,
                height: canvasSize,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) => _addPoint(event.localPosition),
                  onPointerMove: (event) => _addPoint(event.localPosition),
                  onPointerUp: (_) => _endStroke(),
                  child: Stack(
                    children: [
                      if (showImage)
                        Opacity(
                          opacity: 0.2,
                          child: Image.network(
                            widget.imageUrl,
                            width: canvasSize,
                            height: canvasSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Text('Image not available')),
                          ),
                        ),
                      if (showGrid)
                        CustomPaint(
                          size: Size(canvasSize, canvasSize),
                          painter: GridPainter(columns: 2, rows: 2),
                        ),
                      CustomPaint(
                        size: Size(canvasSize, canvasSize),
                        painter: DrawingPainter(points: points),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addPoint(Offset point) {
    setState(() {
      points = List.from(points)..add(point);
    });
  }

  void _endStroke() {
    setState(() {
      points = List.from(points)..add(null);
    });
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

    for (int i = 1; i < columns; i++) {
      canvas.drawLine(
        Offset(cellWidth * i, 0),
        Offset(cellWidth * i, size.height),
        paintGrid,
      );
    }

    for (int j = 1; j < rows; j++) {
      canvas.drawLine(
        Offset(0, cellHeight * j),
        Offset(size.width, cellHeight * j),
        paintGrid,
      );
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
