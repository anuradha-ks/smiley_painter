// In-Class Activity 06 — Drawing with Flutter
// Student: Sai Anuradha Kappaganthula
// Date: September 30, 2026

import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SmileyApp());
}

// ============================================================
// FACE TYPES
// ============================================================

enum FaceType {
  classic,
  sleepy,
  surprised,
}

// ============================================================
// FACE CONFIGURATION
// ============================================================

class FaceConfig {
  final double mood;
  final Color faceColor;
  final FaceType faceType;
  final bool hat;
  final bool glasses;
  final bool mustache;

  const FaceConfig({
    required this.mood,
    required this.faceColor,
    required this.faceType,
    required this.hat,
    required this.glasses,
    required this.mustache,
  });

  FaceConfig copy() {
    return FaceConfig(
      mood: mood,
      faceColor: faceColor,
      faceType: faceType,
      hat: hat,
      glasses: glasses,
      mustache: mustache,
    );
  }
}

// ============================================================
// APP
// ============================================================

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomPainter Smiley Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  double mood = 0.8;

  FaceType selectedFace = FaceType.classic;

  Color faceColor = Colors.orange.shade300;

  bool showHat = false;
  bool showGlasses = false;
  bool showMustache = false;

  final List<FaceConfig> undoStack = [];

  // ==========================================================
  // SAVE CURRENT CONFIGURATION
  // ==========================================================

  void saveCurrentConfig() {
    undoStack.add(
      FaceConfig(
        mood: mood,
        faceColor: faceColor,
        faceType: selectedFace,
        hat: showHat,
        glasses: showGlasses,
        mustache: showMustache,
      ),
    );
  }

  // ==========================================================
  // SHOW MESSAGE
  // ==========================================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==========================================================
  // GET COLOR FOR MOOD
  // ==========================================================

  Color colorForMood(double value) {
    if (value < 0.35) {
      return Colors.lightBlue.shade300;
    } else if (value <= 0.70) {
      return Colors.yellow.shade600;
    } else {
      return Colors.orange.shade300;
    }
  }

  // ==========================================================
  // CHANGE FACE
  // ==========================================================

  void selectFace(FaceType face) {
    if (selectedFace == face) {
      return;
    }

    saveCurrentConfig();

    setState(() {
      selectedFace = face;
    });

    showMessage(
      '${faceName(face)} face selected',
    );
  }

  // ==========================================================
  // FACE NAME
  // ==========================================================

  String faceName(FaceType face) {
    switch (face) {
      case FaceType.classic:
        return 'Classic';
      case FaceType.sleepy:
        return 'Sleepy';
      case FaceType.surprised:
        return 'Surprised';
    }
  }

  // ==========================================================
  // CYCLE FACE
  // ==========================================================

  void cycleFace() {
    saveCurrentConfig();

    setState(() {
      switch (selectedFace) {
        case FaceType.classic:
          selectedFace = FaceType.sleepy;
          break;

        case FaceType.sleepy:
          selectedFace = FaceType.surprised;
          break;

        case FaceType.surprised:
          selectedFace = FaceType.classic;
          break;
      }
    });

    showMessage(
      'Changed to ${faceName(selectedFace)} face',
    );
  }

  // ==========================================================
  // RANDOMIZE MOOD + COLOR
  // ==========================================================

  void randomizeFace() {
    saveCurrentConfig();

    final random = math.Random();

    final newMood = random.nextDouble();
    final newColor = colorForMood(newMood);

    setState(() {
      mood = newMood;
      faceColor = newColor;
    });

    showMessage(
      'Randomized mood to ${newMood.toStringAsFixed(2)}',
    );
  }

  // ==========================================================
  // TOGGLE HAT
  // ==========================================================

  void toggleHat() {
    saveCurrentConfig();

    setState(() {
      showHat = !showHat;
    });

    showMessage(
      showHat ? 'Hat added' : 'Hat removed',
    );
  }

  // ==========================================================
  // TOGGLE GLASSES
  // ==========================================================

  void toggleGlasses() {
    saveCurrentConfig();

    setState(() {
      showGlasses = !showGlasses;
    });

    showMessage(
      showGlasses ? 'Glasses added' : 'Glasses removed',
    );
  }

  // ==========================================================
  // TOGGLE MUSTACHE
  // ==========================================================

  void toggleMustache() {
    saveCurrentConfig();

    setState(() {
      showMustache = !showMustache;
    });

    showMessage(
      showMustache ? 'Mustache added' : 'Mustache removed',
    );
  }

  // ==========================================================
  // UNDO
  // ==========================================================

  void undo() {
    if (undoStack.isEmpty) {
      showMessage('Nothing to undo');
      return;
    }

    final previous = undoStack.removeLast();

    setState(() {
      mood = previous.mood;
      faceColor = previous.faceColor;
      selectedFace = previous.faceType;
      showHat = previous.hat;
      showGlasses = previous.glasses;
      showMustache = previous.mustache;
    });

    showMessage('Previous configuration restored');
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
        actions: [
          IconButton(
            onPressed: undoStack.isEmpty ? null : undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // DRAWING AREA
            // ==================================================

            Expanded(
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,

                  // LEVEL 4:
                  // Tap cycles faces
                  onTap: cycleFace,

                  // LEVEL 4:
                  // Long press randomizes mood/color
                  onLongPress: randomizeFace,

                  child: CustomPaint(
                    size: const Size(300, 300),

                    painter: SmileyPainter(
                      mood: mood,
                      faceColor: faceColor,
                      faceType: selectedFace,
                      showHat: showHat,
                      showGlasses: showGlasses,
                      showMustache: showMustache,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // FACE SELECTION
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Classic'),
                      selected: selectedFace == FaceType.classic,
                      onSelected: (_) {
                        selectFace(FaceType.classic);
                      },
                    ),

                    const SizedBox(width: 8),

                    ChoiceChip(
                      label: const Text('Sleepy'),
                      selected: selectedFace == FaceType.sleepy,
                      onSelected: (_) {
                        selectFace(FaceType.sleepy);
                      },
                    ),

                    const SizedBox(width: 8),

                    ChoiceChip(
                      label: const Text('Surprised'),
                      selected: selectedFace == FaceType.surprised,
                      onSelected: (_) {
                        selectFace(FaceType.surprised);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // MOOD SLIDER
            // ==================================================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  Text(
                    'Mood: ${mood.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Slider(
                    value: mood,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,

                    onChangeStart: (_) {
                      saveCurrentConfig();
                    },

                    onChanged: (double value) {
                      setState(() {
                        mood = value;
                        faceColor = colorForMood(value);
                      });
                    },
                  ),
                ],
              ),
            ),

            // ==================================================
            // ACCESSORIES
            // ==================================================

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: toggleHat,
                    icon: Icon(
                      Icons.face,
                      color: showHat
                          ? Colors.indigo
                          : Colors.grey,
                    ),
                    tooltip: 'Hat',
                  ),

                  IconButton(
                    onPressed: toggleGlasses,
                    icon: Icon(
                      Icons.visibility,
                      color: showGlasses
                          ? Colors.indigo
                          : Colors.grey,
                    ),
                    tooltip: 'Glasses',
                  ),

                  IconButton(
                    onPressed: toggleMustache,
                    icon: Icon(
                      Icons.face_3,
                      color: showMustache
                          ? Colors.indigo
                          : Colors.grey,
                    ),
                    tooltip: 'Mustache',
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Tap face • Long press',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(width: 8),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOM PAINTER
// ============================================================

class SmileyPainter extends CustomPainter {
  final double mood;
  final Color faceColor;
  final FaceType faceType;

  final bool showHat;
  final bool showGlasses;
  final bool showMustache;

  SmileyPainter({
    required this.mood,
    required this.faceColor,
    required this.faceType,
    required this.showHat,
    required this.showGlasses,
    required this.showMustache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ========================================================
    // CENTER + RADIUS
    // ========================================================

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.shortestSide * 0.40;

    // ========================================================
    // FACE
    // ========================================================

    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // ========================================================
    // FACE BORDER
    // ========================================================

    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      center,
      radius,
      borderPaint,
    );

    // ========================================================
    // DRAW FACE TYPE
    // ========================================================

    switch (faceType) {
      case FaceType.classic:
        drawClassicFace(
          canvas,
          center,
          radius,
        );
        break;

      case FaceType.sleepy:
        drawSleepyFace(
          canvas,
          center,
          radius,
        );
        break;

      case FaceType.surprised:
        drawSurprisedFace(
          canvas,
          center,
          radius,
        );
        break;
    }

    // ========================================================
    // ACCESSORIES
    // ========================================================

    if (showGlasses) {
      drawGlasses(
        canvas,
        center,
        radius,
      );
    }

    if (showMustache) {
      drawMustache(
        canvas,
        center,
        radius,
      );
    }

    if (showHat) {
      drawHat(
        canvas,
        center,
        radius,
      );
    }
  }

  // ==========================================================
  // CLASSIC FACE
  // ==========================================================

  void drawClassicFace(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeRadius = radius * 0.10;

    final eyeY = center.dy - radius * 0.18;

    final eyeDx = radius * 0.35;

    final leftEye = Offset(
      center.dx - eyeDx,
      eyeY,
    );

    final rightEye = Offset(
      center.dx + eyeDx,
      eyeY,
    );

    canvas.drawCircle(
      leftEye,
      eyeRadius,
      eyePaint,
    );

    canvas.drawCircle(
      rightEye,
      eyeRadius,
      eyePaint,
    );

    // Eye highlights for happy mood

    if (mood > 0.7) {
      final highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        leftEye + Offset(
          -eyeRadius * 0.3,
          -eyeRadius * 0.3,
        ),
        eyeRadius * 0.3,
        highlightPaint,
      );

      canvas.drawCircle(
        rightEye + Offset(
          -eyeRadius * 0.3,
          -eyeRadius * 0.3,
        ),
        eyeRadius * 0.3,
        highlightPaint,
      );
    }

    // Eyebrows

    final eyebrowPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    if (mood < 0.35) {
      // Sad eyebrows

      canvas.drawLine(
        Offset(
          leftEye.dx - eyeRadius,
          eyeY - radius * 0.17,
        ),
        Offset(
          leftEye.dx + eyeRadius,
          eyeY - radius * 0.27,
        ),
        eyebrowPaint,
      );

      canvas.drawLine(
        Offset(
          rightEye.dx - eyeRadius,
          eyeY - radius * 0.27,
        ),
        Offset(
          rightEye.dx + eyeRadius,
          eyeY - radius * 0.17,
        ),
        eyebrowPaint,
      );
    }

    // Blush

    if (mood > 0.7) {
      final blushPaint = Paint()
        ..color = Colors.pink.withOpacity(0.45)
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx - radius * 0.58,
            center.dy + radius * 0.12,
          ),
          width: radius * 0.35,
          height: radius * 0.16,
        ),
        blushPaint,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx + radius * 0.58,
            center.dy + radius * 0.12,
          ),
          width: radius * 0.35,
          height: radius * 0.16,
        ),
        blushPaint,
      );
    }

    // Mouth

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (mood < 0.35) {
      final frownRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.28,
        ),
        width: radius * 0.95,
        height: radius * 0.55,
      );

      canvas.drawArc(
        frownRect,
        1.15 * math.pi,
        0.70 * math.pi,
        false,
        mouthPaint,
      );
    } else if (mood <= 0.7) {
      final smileRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.08,
        ),
        width: radius,
        height: radius * 0.65,
      );

      canvas.drawArc(
        smileRect,
        0.15 * math.pi,
        0.70 * math.pi,
        false,
        mouthPaint,
      );
    } else {
      final mouthPaintFill = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.20,
        ),
        width: radius * 0.85,
        height: radius * 0.60,
      );

      canvas.drawOval(
        mouthRect,
        mouthPaintFill,
      );

      final tonguePaint = Paint()
        ..color = Colors.pinkAccent
        ..style = PaintingStyle.fill;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy + radius * 0.38,
          ),
          width: radius * 0.48,
          height: radius * 0.22,
        ),
        tonguePaint,
      );
    }
  }

  // ==========================================================
  // SLEEPY FACE
  // ==========================================================

  void drawSleepyFace(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final eyeY = center.dy - radius * 0.15;

    final eyeDx = radius * 0.35;

    // Closed left eye

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(
          center.dx - eyeDx,
          eyeY,
        ),
        width: radius * 0.38,
        height: radius * 0.22,
      ),
      0,
      math.pi,
      false,
      eyePaint,
    );

    // Closed right eye

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(
          center.dx + eyeDx,
          eyeY,
        ),
        width: radius * 0.38,
        height: radius * 0.22,
      ),
      0,
      math.pi,
      false,
      eyePaint,
    );

    // Sleepy mouth

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.15,
        ),
        width: radius * 0.75,
        height: radius * 0.45,
      ),
      0.15 * math.pi,
      0.70 * math.pi,
      false,
      eyePaint,
    );

    // Small "Z"

    final zPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();

    path.moveTo(
      center.dx + radius * 0.55,
      center.dy - radius * 0.55,
    );

    path.lineTo(
      center.dx + radius * 0.70,
      center.dy - radius * 0.55,
    );

    path.lineTo(
      center.dx + radius * 0.55,
      center.dy - radius * 0.40,
    );

    path.lineTo(
      center.dx + radius * 0.70,
      center.dy - radius * 0.40,
    );

    canvas.drawPath(
      path,
      zPaint,
    );
  }

  // ==========================================================
  // SURPRISED FACE
  // ==========================================================

  void drawSurprisedFace(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeRadius = radius * 0.13;

    final eyeY = center.dy - radius * 0.20;

    final eyeDx = radius * 0.34;

    canvas.drawCircle(
      Offset(
        center.dx - eyeDx,
        eyeY,
      ),
      eyeRadius,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + eyeDx,
        eyeY,
      ),
      eyeRadius,
      eyePaint,
    );

    // Surprised open mouth

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.20,
        ),
        width: radius * 0.50,
        height: radius * 0.65,
      ),
      mouthPaint,
    );

    // Small tongue

    final tonguePaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.42,
        ),
        width: radius * 0.28,
        height: radius * 0.15,
      ),
      tonguePaint,
    );
  }

  // ==========================================================
  // GLASSES
  // ==========================================================

  void drawGlasses(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final glassesPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final eyeY = center.dy - radius * 0.18;

    final eyeDx = radius * 0.35;

    final lensWidth = radius * 0.42;

    final lensHeight = radius * 0.30;

    // Left lens

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx - eyeDx,
          eyeY,
        ),
        width: lensWidth,
        height: lensHeight,
      ),
      glassesPaint,
    );

    // Right lens

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + eyeDx,
          eyeY,
        ),
        width: lensWidth,
        height: lensHeight,
      ),
      glassesPaint,
    );

    // Bridge

    canvas.drawLine(
      Offset(
        center.dx - eyeDx + lensWidth / 2,
        eyeY,
      ),
      Offset(
        center.dx + eyeDx - lensWidth / 2,
        eyeY,
      ),
      glassesPaint,
    );
  }

  // ==========================================================
  // MUSTACHE
  // ==========================================================

  void drawMustache(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final mustachePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final leftPath = Path();

    leftPath.moveTo(
      center.dx,
      center.dy + radius * 0.30,
    );

    leftPath.quadraticBezierTo(
      center.dx - radius * 0.20,
      center.dy + radius * 0.15,
      center.dx - radius * 0.48,
      center.dy + radius * 0.25,
    );

    leftPath.quadraticBezierTo(
      center.dx - radius * 0.25,
      center.dy + radius * 0.50,
      center.dx,
      center.dy + radius * 0.34,
    );

    leftPath.close();

    canvas.drawPath(
      leftPath,
      mustachePaint,
    );

    final rightPath = Path();

    rightPath.moveTo(
      center.dx,
      center.dy + radius * 0.30,
    );

    rightPath.quadraticBezierTo(
      center.dx + radius * 0.20,
      center.dy + radius * 0.15,
      center.dx + radius * 0.48,
      center.dy + radius * 0.25,
    );

    rightPath.quadraticBezierTo(
      center.dx + radius * 0.25,
      center.dy + radius * 0.50,
      center.dx,
      center.dy + radius * 0.34,
    );

    rightPath.close();

    canvas.drawPath(
      rightPath,
      mustachePaint,
    );
  }

  // ==========================================================
  // HAT
  // ==========================================================

  void drawHat(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final hatPaint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.fill;

    // Hat base

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy - radius * 0.78,
          ),
          width: radius * 1.25,
          height: radius * 0.18,
        ),
        const Radius.circular(8),
      ),
      hatPaint,
    );

    // Hat top

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy - radius * 0.95,
          ),
          width: radius * 0.75,
          height: radius * 0.48,
        ),
        const Radius.circular(10),
      ),
      hatPaint,
    );

    // Hat band

    final bandPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy - radius * 0.83,
        ),
        width: radius * 0.75,
        height: radius * 0.08,
      ),
      bandPaint,
    );
  }

  // ==========================================================
  // SHOULD REPAINT
  // ==========================================================

  @override
  bool shouldRepaint(
    covariant SmileyPainter oldDelegate,
  ) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceColor != faceColor ||
        oldDelegate.faceType != faceType ||
        oldDelegate.showHat != showHat ||
        oldDelegate.showGlasses != showGlasses ||
        oldDelegate.showMustache != showMustache;
  }
}