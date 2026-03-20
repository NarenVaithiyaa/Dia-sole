import 'package:flutter/material.dart';
import 'dart:math' as math;

class FootPressureWidget extends StatelessWidget {
  final double pressureLeftHeel;
  final double pressureLeftToe;
  final double pressureLeftBall;
  final double pressureRightHeel;
  final double pressureRightToe;
  final double pressureRightBall;
  final double tempLeftHeel;
  final double tempLeftToe;
  final double tempLeftBall;
  final double tempRightHeel;
  final double tempRightToe;
  final double tempRightBall;

  const FootPressureWidget({
    super.key,
    this.pressureLeftHeel = 0.5,
    this.pressureLeftToe = 0.3,
    this.pressureLeftBall = 0.4,
    this.pressureRightHeel = 0.8,
    this.pressureRightToe = 0.4,
    this.pressureRightBall = 0.5,
    this.tempLeftHeel = 36.5,
    this.tempLeftToe = 36.6,
    this.tempLeftBall = 36.6,
    this.tempRightHeel = 37.0,
    this.tempRightToe = 36.8,
    this.tempRightBall = 36.9,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            height: 380, // Taller overall height for great proportions
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Foot (Mirrored Right Foot)
                Flexible(
                  child: Transform.scale(
                    scaleX: -1.0,
                    alignment: Alignment.center,
                    child: RightFootWidget(
                      pressureHeel: pressureLeftHeel,
                      pressureToe: pressureLeftToe,
                      pressureBall: pressureLeftBall,
                      tempHeel: tempLeftHeel,
                      tempToe: tempLeftToe,
                      tempBall: tempLeftBall,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Generous central spacing
                // Right Foot (Canonical)
                Flexible(
                  child: RightFootWidget(
                    pressureHeel: pressureRightHeel,
                    pressureToe: pressureRightToe,
                    pressureBall: pressureRightBall,
                    tempHeel: tempRightHeel,
                    tempToe: tempRightToe,
                    tempBall: tempRightBall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            icon: Icons.circle,
            color: Colors.green,
            label: "Pressure\n(Normal)",
          ),
          _buildLegendItem(
            icon: Icons.circle,
            color: Colors.red,
            label: "Pressure\n(Hotspot)",
          ),
          _buildLegendItem(
            icon: Icons.star,
            color: Colors.orange,
            label: "Temp",
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class RightFootWidget extends StatelessWidget {
  final double pressureHeel;
  final double pressureToe;
  final double pressureBall;
  final double tempHeel;
  final double tempToe;
  final double tempBall;

  const RightFootWidget({
    super.key,
    required this.pressureHeel,
    required this.pressureToe,
    required this.pressureBall,
    required this.tempHeel,
    required this.tempToe,
    required this.tempBall,
  });

  @override
  Widget build(BuildContext context) {
    // We enforce an exact aspect ratio so internal geometry is a perfectly mapped 100x240 box
    return AspectRatio(
      aspectRatio: 100 / 240,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          // Accurately matched percentage coordinates strictly within the 100x240 bounding box
          const double toeX = 0.18; // Big toe
          const double toeY = 0.12;

          const double ballX = 0.35; // Medial ball
          const double ballY = 0.32;

          const double heelX = 0.50; // Heel center
          const double heelY = 0.85;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Right Foot Silhouette
              Positioned.fill(child: CustomPaint(painter: FootShapePainter())),

              // 2. Soft Radial Heatmaps
              _buildHeatmap(w, h, toeX, toeY, pressureToe),
              _buildHeatmap(w, h, ballX, ballY, pressureBall),
              _buildHeatmap(w, h, heelX, heelY, pressureHeel),

              // 3. Sensor Anchors
              _buildSensor(w, h, toeX, toeY, pressureToe, tempToe),
              _buildSensor(w, h, ballX, ballY, pressureBall, tempBall),
              _buildSensor(w, h, heelX, heelY, pressureHeel, tempHeel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeatmap(
    double w,
    double h,
    double dx,
    double dy,
    double pressure,
  ) {
    if (pressure <= 0.1) return const SizedBox();

    // Heatmap bloom size based strictly on widget width and pressure value
    double size = w * 0.9 * pressure;

    return Positioned(
      left: (dx * w) - (size / 2),
      top: (dy * h) - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.red.withOpacity(0.6 * pressure),
              Colors.orange.withOpacity(0.4 * pressure),
              Colors.yellow.withOpacity(0.2 * pressure),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
          backgroundBlendMode:
              BlendMode.multiply, // Ensures soft merging on skin tone
        ),
      ),
    );
  }

  Widget _buildSensor(
    double w,
    double h,
    double dx,
    double dy,
    double pressure,
    double temp,
  ) {
    bool isHotspot = pressure >= 0.7; // Normal -> green, Hotspot -> red
    bool isHotTemp = temp > 37.5; // Threshold for temp alert

    Color pressureColor = isHotspot ? Colors.red : Colors.green;
    Color tempColor = isHotTemp ? Colors.red : Colors.orange;

    return Positioned(
      left:
          (dx * w) -
          24, // perfectly center 48x48 bounds over exact target point
      top: (dy * h) - 24,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: tempColor,
              size: 14,
            ), // Unaffected visually by horizontal mirror
            const SizedBox(height: 2),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: pressureColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1), // Vertical shadow unchanged by mirror
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FootShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // The design resolution for our exact points
    const double designWidth = 100;
    const double designHeight = 240;

    // We mathematically contain drawing into size (mimics BoxFit.contain perfectly)
    final double scaleX = size.width / designWidth;
    final double scaleY = size.height / designHeight;
    final double scale = math.min(scaleX, scaleY);

    final double dx = (size.width - designWidth * scale) / 2;
    final double dy = (size.height - designHeight * scale) / 2;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final Path path = Path();

    // Heel bottom (flattened slightly, stable base)
    path.moveTo(42, 238);
    path.cubicTo(50, 239.5, 60, 239.5, 68, 237);

    // Lateral (Outer) Heel sweeping to Midfoot
    path.cubicTo(82, 232, 87, 210, 86, 160);

    // Lateral Forefoot (slightly widened)
    path.cubicTo(85, 110, 95, 85, 87, 57);

    // 5th Toe (Pinky) - angled outward slightly
    path.quadraticBezierTo(83.5, 48, 80, 40);
    path.arcToPoint(
      const Offset(72, 42),
      radius: const Radius.circular(4.2),
      clockwise: false,
    );
    path.quadraticBezierTo(71, 49, 69, 52);

    // 4th Toe
    path.quadraticBezierTo(71, 39, 68, 30);
    path.arcToPoint(
      const Offset(59, 32),
      radius: const Radius.circular(5.0),
      clockwise: false,
    );
    path.quadraticBezierTo(58, 40, 56, 44);

    // 3rd Toe
    path.quadraticBezierTo(57, 30, 54, 21);
    path.arcToPoint(
      const Offset(44, 23),
      radius: const Radius.circular(6.2),
      clockwise: false,
    );
    path.quadraticBezierTo(43, 33, 41, 38);

    // 2nd Toe
    path.quadraticBezierTo(42, 23, 39, 12);
    path.arcToPoint(
      const Offset(27, 14),
      radius: const Radius.circular(7.8),
      clockwise: false,
    );
    path.quadraticBezierTo(26, 25, 24, 30);

    // 1st Toe (Big Toe) - larger, more prominent
    path.quadraticBezierTo(26, 13, 22, 1);
    path.arcToPoint(
      const Offset(4, 6),
      radius: const Radius.circular(12.5),
      clockwise: false,
    );

    // Medial drop down from big toe
    path.quadraticBezierTo(3, 24, 11, 46);

    // Medial Forefoot (Ball of the foot - widened)
    path.cubicTo(15, 58, 22, 75, 25, 90);

    // Plantar Arch (Smooth continuous S-curve)
    path.cubicTo(28, 115, 49, 145, 51, 175);

    // Medial Heel looping back
    path.cubicTo(53, 205, 34, 235, 42, 238);

    path.close();

    // Natural skin tone
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE0CB), Color(0xFFEBC1A8)],
      ).createShader(const Rect.fromLTWH(0, 0, designWidth, designHeight))
      ..style = PaintingStyle.fill;

    // Clean edge outline
    final Paint strokePaint = Paint()
      ..color = const Color(0xFFD7B29D)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          2.0 / scale; // Neutralizes zoom distortion on line thickness

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
