import 'package:flutter/material.dart';
import 'dart:math' as math;

class FootPressureWidget extends StatelessWidget {
  final double pressureLeftHeel;
  final double pressureLeftToe;
  final double pressureLeftBall;
  final double pressureRightHeel;
  final double pressureRightToe;
  final double pressureLeftOppositeHeel;
  final double pressureLeftOppositeToe;
  final double pressureLeftOppositeBall;
  final double pressureRightOppositeHeel;
  final double pressureRightOppositeToe;
  final double pressureRightOppositeBall;
  final double pressureRightBall;
  final double tempLeftHeel;
  final double tempLeftToe;
  final double tempLeftBall;
  final double tempLeftOppositeHeel;
  final double tempLeftOppositeToe;
  final double tempLeftOppositeBall;
  final double tempRightHeel;
  final double tempRightToe;
  final double tempRightBall;
  final double tempRightOppositeHeel;
  final double tempRightOppositeToe;
  final double tempRightOppositeBall;

  const FootPressureWidget({
    super.key,
    this.pressureLeftHeel = 0.5,
    this.pressureLeftToe = 0.3,
    this.pressureLeftBall = 0.4,
    this.pressureLeftOppositeHeel = 0.5,
    this.pressureLeftOppositeToe = 0.3,
    this.pressureLeftOppositeBall = 0.4,
    this.pressureRightHeel = 0.8,
    this.pressureRightToe = 0.4,
    this.pressureRightBall = 0.5,
    this.pressureRightOppositeHeel = 0.8,
    this.pressureRightOppositeToe = 0.4,
    this.pressureRightOppositeBall = 0.5,
    this.tempLeftHeel = 36.5,
    this.tempLeftToe = 36.6,
    this.tempLeftBall = 36.6,
    this.tempLeftOppositeHeel = 36.5,
    this.tempLeftOppositeToe = 36.6,
    this.tempLeftOppositeBall = 36.6,
    this.tempRightHeel = 37.0,
    this.tempRightToe = 36.8,
    this.tempRightBall = 36.9,
    this.tempRightOppositeHeel = 37.0,
    this.tempRightOppositeToe = 36.8,
    this.tempRightOppositeBall = 36.9,
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
                      footSide: "Left",
                      pressureHeel: pressureLeftHeel,
                      pressureToe: pressureLeftToe,
                      pressureBall: pressureLeftBall,
                      pressureOppositeHeel: pressureLeftOppositeHeel,
                      pressureOppositeToe: pressureLeftOppositeToe,
                      pressureOppositeBall: pressureLeftOppositeBall,
                      tempHeel: tempLeftHeel,
                      tempToe: tempLeftToe,
                      tempBall: tempLeftBall,
                      tempOppositeHeel: tempLeftOppositeHeel,
                      tempOppositeToe: tempLeftOppositeToe,
                      tempOppositeBall: tempLeftOppositeBall,
                    ),
                  ),
                ),
                const SizedBox(width: 40), // Generous central spacing
                // Right Foot (Canonical)
                Flexible(
                  child: RightFootWidget(
                    footSide: "Right",
                    pressureHeel: pressureRightHeel,
                    pressureToe: pressureRightToe,
                    pressureBall: pressureRightBall,
                    pressureOppositeHeel: pressureRightOppositeHeel,
                    pressureOppositeToe: pressureRightOppositeToe,
                    pressureOppositeBall: pressureRightOppositeBall,
                    tempHeel: tempRightHeel,
                    tempToe: tempRightToe,
                    tempBall: tempRightBall,
                    tempOppositeHeel: tempRightOppositeHeel,
                    tempOppositeToe: tempRightOppositeToe,
                    tempOppositeBall: tempRightOppositeBall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(),
        const SizedBox(height: 24),
        _buildHealthAnalysis(),
      ],
    );
  }

  Widget _buildHealthAnalysis() {
    // Determine absolute temperature differences between corresponding points
    double diffToe = (tempLeftToe - tempRightToe).abs();
    double diffBall = (tempLeftBall - tempRightBall).abs();
    double diffHeel = (tempLeftHeel - tempRightHeel).abs();

    String status(double diff) =>
        diff > 2.0 ? "Temperature Abnormal" : "Temperature Normal";
    Color statusColor(double diff) => diff > 2.0 ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Foot Health Analysis",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisRow(
            "Toe Area Difference",
            diffToe,
            status(diffToe),
            statusColor(diffToe),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildAnalysisRow(
            "Ball Area Difference",
            diffBall,
            status(diffBall),
            statusColor(diffBall),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildAnalysisRow(
            "Heel Area Difference",
            diffHeel,
            status(diffHeel),
            statusColor(diffHeel),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(
    String title,
    double diff,
    String status,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${diff.toStringAsFixed(1)} °C",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
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
  final String footSide;
  final double pressureHeel;
  final double pressureToe;
  final double pressureBall;
  final double pressureOppositeHeel;
  final double pressureOppositeToe;
  final double pressureOppositeBall;
  final double tempHeel;
  final double tempToe;
  final double tempBall;
  final double tempOppositeHeel;
  final double tempOppositeToe;
  final double tempOppositeBall;

  const RightFootWidget({
    super.key,
    this.footSide = "Right",
    required this.pressureHeel,
    required this.pressureToe,
    required this.pressureBall,
    required this.pressureOppositeHeel,
    required this.pressureOppositeToe,
    required this.pressureOppositeBall,
    required this.tempHeel,
    required this.tempToe,
    required this.tempBall,
    required this.tempOppositeHeel,
    required this.tempOppositeToe,
    required this.tempOppositeBall,
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
          
          // Exactly Opposite Places
          const double oppToeX = 0.75; 
          const double oppToeY = 0.18;
          
          const double oppBallX = 0.75; 
          const double oppBallY = 0.35;
          
          const double oppHeelX = 0.50; 
          const double oppHeelY = 0.55;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Right Foot Silhouette
              Positioned.fill(child: CustomPaint(painter: FootShapePainter())),

              // 2. Soft Radial Heatmaps
              _buildHeatmap(w, h, toeX, toeY, pressureToe),
              _buildHeatmap(w, h, ballX, ballY, pressureBall),
              _buildHeatmap(w, h, heelX, heelY, pressureHeel),
              _buildHeatmap(w, h, oppToeX, oppToeY, pressureOppositeToe),
              _buildHeatmap(w, h, oppBallX, oppBallY, pressureOppositeBall),
              _buildHeatmap(w, h, oppHeelX, oppHeelY, pressureOppositeHeel),

              // 3. Sensor Anchors
              _buildSensor(context, w, h, toeX, toeY, pressureToe, tempToe, "Toe"),
              _buildSensor(context, w, h, ballX, ballY, pressureBall, tempBall, "Ball"),
              _buildSensor(context, w, h, heelX, heelY, pressureHeel, tempHeel, "Heel"),
              _buildSensor(context, w, h, oppToeX, oppToeY, pressureOppositeToe, tempOppositeToe, "OpToe"),
              _buildSensor(context, w, h, oppBallX, oppBallY, pressureOppositeBall, tempOppositeBall, "OpBall"),
              _buildSensor(context, w, h, oppHeelX, oppHeelY, pressureOppositeHeel, tempOppositeHeel, "OpHeel"),
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
    if (pressure <= 10.0) return const SizedBox();

    double normalizedPressure = (pressure / 100.0).clamp(0.0, 1.0);

    // Heatmap bloom size based strictly on widget width and pressure value
    double size = w * 0.9 * normalizedPressure;

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
              Colors.red.withValues(alpha: 0.6 * normalizedPressure),
              Colors.orange.withValues(alpha: 0.4 * normalizedPressure),
              Colors.yellow.withValues(alpha: 0.2 * normalizedPressure),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
          // backgroundBlendMode: BlendMode.multiply, // Removed to prevent full screen red tint bug
        ),
      ),
    );
  }

  Widget _buildSensor(
    BuildContext context,
    double w,
    double h,
    double dx,
    double dy,
    double pressure,
    double temp,
    String pointName,
  ) {
    bool isHotspot = pressure >= 70.0; // Normal -> green, Hotspot -> red
    bool isHotTemp = temp > 37.5; // Threshold for temp alert

    Color pressureColor = isHotspot ? Colors.red : Colors.green;
    Color tempColor = isHotTemp ? Colors.red : Colors.orange;

    return Positioned(
      left:
          (dx * w) -
          24, // perfectly center 48x48 bounds over exact target point
      top: (dy * h) - 24,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('$footSide $pointName Sensor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pressure: ${pressure.toStringAsFixed(1)} kPa',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temperature: ${temp.toStringAsFixed(1)} °C',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: SizedBox(
          width: 48,
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reverse the transform on the icon so it doesn't look weird if side is Left
              Transform.scale(
                scaleX: footSide == "Left" ? -1.0 : 1.0,
                child: Icon(Icons.star, color: tempColor, size: 14),
              ),
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
                      offset: Offset(
                        0,
                        1,
                      ), // Vertical shadow unchanged by mirror
                    ),
                  ],
                ),
              ),
            ],
          ),
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
