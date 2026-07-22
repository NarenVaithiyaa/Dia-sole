import 'package:flutter/material.dart';

class FootPressureWidget extends StatefulWidget {
  final double pressureLeftS1;
  final double pressureLeftS2;
  final double pressureLeftS3;
  final double pressureLeftS4;
  final double pressureLeftS5;
  final double pressureLeftS6;

  final double pressureRightS1;
  final double pressureRightS2;
  final double pressureRightS3;
  final double pressureRightS4;
  final double pressureRightS5;
  final double pressureRightS6;

  final double tempLeftS1;
  final double tempLeftS2;
  final double tempLeftS3;
  final double tempLeftS4;
  final double tempLeftS6;

  final double tempRightS1;
  final double tempRightS2;
  final double tempRightS3;
  final double tempRightS4;
  final double tempRightS6;

  const FootPressureWidget({
    super.key,
    this.pressureLeftS1 = 0.5,
    this.pressureLeftS2 = 0.3,
    this.pressureLeftS3 = 0.4,
    this.pressureLeftS4 = 0.5,
    this.pressureLeftS5 = 0.3,
    this.pressureLeftS6 = 0.4,
    this.pressureRightS1 = 0.8,
    this.pressureRightS2 = 0.4,
    this.pressureRightS3 = 0.5,
    this.pressureRightS4 = 0.8,
    this.pressureRightS5 = 0.4,
    this.pressureRightS6 = 0.5,
    this.tempLeftS1 = 36.5,
    this.tempLeftS2 = 36.6,
    this.tempLeftS3 = 36.6,
    this.tempLeftS4 = 36.5,
    this.tempLeftS6 = 36.6,
    this.tempRightS1 = 37.0,
    this.tempRightS2 = 36.8,
    this.tempRightS3 = 36.9,
    this.tempRightS4 = 37.0,
    this.tempRightS6 = 36.8,
  });

  @override
  State<FootPressureWidget> createState() => _FootPressureWidgetState();
}

class _FootPressureWidgetState extends State<FootPressureWidget> {
  String _selectedFoot = "Right";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFootSelector(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Values
            Expanded(
              flex: 5,
              child: _buildValuesList(),
            ),
            const SizedBox(width: 8),
            // Right side: Image
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 380,
                child: _selectedFoot == "Left"
                    ? Transform.scale(
                        scaleX: -1.0,
                        alignment: Alignment.center,
                        child: FootImageWidget(
                          footSide: "Left",
                          pressureS1: widget.pressureLeftS1,
                          pressureS2: widget.pressureLeftS2,
                          pressureS3: widget.pressureLeftS3,
                          pressureS4: widget.pressureLeftS4,
                          pressureS5: widget.pressureLeftS5,
                          pressureS6: widget.pressureLeftS6,
                          tempS1: widget.tempLeftS1,
                          tempS2: widget.tempLeftS2,
                          tempS3: widget.tempLeftS3,
                          tempS4: widget.tempLeftS4,
                          tempS6: widget.tempLeftS6,
                        ),
                      )
                    : FootImageWidget(
                        footSide: "Right",
                        pressureS1: widget.pressureRightS1,
                        pressureS2: widget.pressureRightS2,
                        pressureS3: widget.pressureRightS3,
                        pressureS4: widget.pressureRightS4,
                        pressureS5: widget.pressureRightS5,
                        pressureS6: widget.pressureRightS6,
                        tempS1: widget.tempRightS1,
                        tempS2: widget.tempRightS2,
                        tempS3: widget.tempRightS3,
                        tempS4: widget.tempRightS4,
                        tempS6: widget.tempRightS6,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLegend(),
        const SizedBox(height: 24),
        _buildHealthAnalysis(),
      ],
    );
  }

  Widget _buildFootSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFootTab("Left"),
          _buildFootTab("Right"),
        ],
      ),
    );
  }

  Widget _buildFootTab(String side) {
    bool isSelected = _selectedFoot == side;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFoot = side;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
              : [],
        ),
        child: Text(
          "$side Foot",
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildValuesList() {
    return Column(
      children: [
        _buildValueCard("1", "Toe",
            _selectedFoot == "Left" ? widget.pressureLeftS1 : widget.pressureRightS1,
            _selectedFoot == "Left" ? widget.tempLeftS1 : widget.tempRightS1),
        _buildValueCard("2", "Inner Ball",
            _selectedFoot == "Left" ? widget.pressureLeftS2 : widget.pressureRightS2,
            _selectedFoot == "Left" ? widget.tempLeftS2 : widget.tempRightS2),
        _buildValueCard("3", "Mid Ball",
            _selectedFoot == "Left" ? widget.pressureLeftS3 : widget.pressureRightS3,
            _selectedFoot == "Left" ? widget.tempLeftS3 : widget.tempRightS3),
        _buildValueCard("4", "Outer Ball",
            _selectedFoot == "Left" ? widget.pressureLeftS4 : widget.pressureRightS4,
            _selectedFoot == "Left" ? widget.tempLeftS4 : widget.tempRightS4),
        _buildValueCard("5", "Midfoot",
            _selectedFoot == "Left" ? widget.pressureLeftS5 : widget.pressureRightS5,
            null),
        _buildValueCard("6", "Heel",
            _selectedFoot == "Left" ? widget.pressureLeftS6 : widget.pressureRightS6,
            _selectedFoot == "Left" ? widget.tempLeftS6 : widget.tempRightS6),
      ],
    );
  }

  Widget _buildValueCard(String number, String label, double pressure, double? temp) {
    bool isHotspot = pressure >= 70.0;
    bool isHotTemp = temp != null && temp > 37.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: isHotspot ? Colors.red : Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "${pressure.toStringAsFixed(1)} kPa",
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                if (temp != null)
                  Row(
                    children: [
                      Icon(Icons.star, size: 8, color: isHotTemp ? Colors.red : Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${temp.toStringAsFixed(1)} °C",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAnalysis() {
    // Determine absolute temperature differences between corresponding points
    double diffS1 = (widget.tempLeftS1 - widget.tempRightS1).abs();
    double diffS3 = (widget.tempLeftS3 - widget.tempRightS3).abs();
    double diffS6 = (widget.tempLeftS6 - widget.tempRightS6).abs();

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
            "S1 (Toe) Area Difference",
            diffS1,
            status(diffS1),
            statusColor(diffS1),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildAnalysisRow(
            "S3 (Ball) Area Difference",
            diffS3,
            status(diffS3),
            statusColor(diffS3),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildAnalysisRow(
            "S6 (Heel) Area Difference",
            diffS6,
            status(diffS6),
            statusColor(diffS6),
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

class FootImageWidget extends StatelessWidget {
  final String footSide;
  final double pressureS1;
  final double pressureS2;
  final double pressureS3;
  final double pressureS4;
  final double pressureS5;
  final double pressureS6;

  final double tempS1;
  final double tempS2;
  final double tempS3;
  final double tempS4;
  final double tempS6;

  const FootImageWidget({
    super.key,
    this.footSide = "Right",
    required this.pressureS1,
    required this.pressureS2,
    required this.pressureS3,
    required this.pressureS4,
    required this.pressureS5,
    required this.pressureS6,
    required this.tempS1,
    required this.tempS2,
    required this.tempS3,
    required this.tempS4,
    required this.tempS6,
  });

  @override
  Widget build(BuildContext context) {
    // Adjust aspect ratio based on realistic foot image
    return AspectRatio(
      aspectRatio: 100 / 240,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          // Mapping according to the technical specification:
          // For Right foot:
          // S1: Inner top (big toe)
          const double s1X = 0.35;
          const double s1Y = 0.15;
          
          // S2: Inner ball
          const double s2X = 0.35;
          const double s2Y = 0.35;
          
          // S3: Middle ball
          const double s3X = 0.50;
          const double s3Y = 0.32;
          
          // S4: Outer ball
          const double s4X = 0.70;
          const double s4Y = 0.40;
          
          // S5: Midfoot (center arch area)
          const double s5X = 0.50;
          const double s5Y = 0.60;
          
          // S6: Heel (center)
          const double s6X = 0.50;
          const double s6Y = 0.82;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Realistic Right Foot Image
              Positioned.fill(
                child: ClipRect(
                  child: Image.asset(
                    'assets/images/foot_diagram.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Soft Radial Heatmaps
              _buildHeatmap(w, h, s1X, s1Y, pressureS1),
              _buildHeatmap(w, h, s2X, s2Y, pressureS2),
              _buildHeatmap(w, h, s3X, s3Y, pressureS3),
              _buildHeatmap(w, h, s4X, s4Y, pressureS4),
              _buildHeatmap(w, h, s5X, s5Y, pressureS5),
              _buildHeatmap(w, h, s6X, s6Y, pressureS6),

              // 3. Sensor Anchors
              _buildSensor(context, w, h, s1X, s1Y, pressureS1, tempS1, "S1 (Toe)"),
              _buildSensor(context, w, h, s2X, s2Y, pressureS2, tempS2, "S2 (Inner Ball)"),
              _buildSensor(context, w, h, s3X, s3Y, pressureS3, tempS3, "S3 (Mid Ball)"),
              _buildSensor(context, w, h, s4X, s4Y, pressureS4, tempS4, "S4 (Outer Ball)"),
              _buildSensor(context, w, h, s5X, s5Y, pressureS5, null, "S5 (Midfoot)"), // No Temp for S5
              _buildSensor(context, w, h, s6X, s6Y, pressureS6, tempS6, "S6 (Heel)"),
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

    // Heatmap bloom size
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
    double? temp, // Nullable since S5 doesn't have temperature
    String pointName,
  ) {
    bool isHotspot = pressure >= 70.0;
    bool isHotTemp = temp != null && temp > 37.5;

    Color pressureColor = isHotspot ? Colors.red : Colors.green;
    Color tempColor = isHotTemp ? Colors.red : Colors.orange;

    return Positioned(
      left: (dx * w) - 24, // perfectly center 48x48 bounds over exact target point
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
                  if (temp != null)
                    Text(
                      'Temperature: ${temp.toStringAsFixed(1)} °C',
                      style: const TextStyle(fontSize: 16),
                    )
                  else
                    const Text(
                      'Temperature: N/A',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
              if (temp != null)
                Transform.scale(
                  scaleX: footSide == "Left" ? -1.0 : 1.0,
                  child: Icon(Icons.star, color: tempColor, size: 14),
                )
              else
                const SizedBox(height: 14), // Spacer for missing temp icon
              const SizedBox(height: 2),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: pressureColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Transform.scale(
                    scaleX: footSide == "Left" ? -1.0 : 1.0,
                    child: Text(
                      pointName.substring(1, 2),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
