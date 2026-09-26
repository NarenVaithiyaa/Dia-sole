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
  String _selectedTab = "Overview";
  String _displayType = "Pressure";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFootSelector(),
        const SizedBox(height: 12),
        _buildDisplayTypeSelector(),
        const SizedBox(height: 16),
        if (_selectedTab == "Overview")
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text("Left Foot", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildValuesList("Left"),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text("Right Foot", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    _buildValuesList("Right"),
                  ],
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            child: _selectedTab == "Left"
                ? Transform.scale(
                    scaleX: -1.0,
                    alignment: Alignment.center,
                    child: FootImageWidget(
                      footSide: "Left",
                      displayType: _displayType,
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
                      tempS1Diff: (widget.tempLeftS1 - widget.tempRightS1).abs(),
                      tempS2Diff: (widget.tempLeftS2 - widget.tempRightS2).abs(),
                      tempS3Diff: (widget.tempLeftS3 - widget.tempRightS3).abs(),
                      tempS4Diff: (widget.tempLeftS4 - widget.tempRightS4).abs(),
                      tempS6Diff: (widget.tempLeftS6 - widget.tempRightS6).abs(),
                    ),
                  )
                : FootImageWidget(
                    footSide: "Right",
                    displayType: _displayType,
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
                    tempS1Diff: (widget.tempLeftS1 - widget.tempRightS1).abs(),
                    tempS2Diff: (widget.tempLeftS2 - widget.tempRightS2).abs(),
                    tempS3Diff: (widget.tempLeftS3 - widget.tempRightS3).abs(),
                    tempS4Diff: (widget.tempLeftS4 - widget.tempRightS4).abs(),
                    tempS6Diff: (widget.tempLeftS6 - widget.tempRightS6).abs(),
                  ),
          ),
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
        children: [
          Expanded(child: _buildFootTab("Overview")),
          Expanded(child: _buildFootTab("Left")),
          Expanded(child: _buildFootTab("Right")),
        ],
      ),
    );
  }

  Widget _buildFootTab(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
              : [],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title == "Overview" ? "Overview" : "$title Foot",
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildDisplayTab("Pressure")),
          Expanded(child: _buildDisplayTab("Temperature")),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(String title) {
    bool isSelected = _displayType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _displayType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 4)]
              : [],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValuesList(String side) {
    bool isLeft = side == "Left";
    return Column(
      children: [
        _buildValueCard("1",
            isLeft ? widget.pressureLeftS1 : widget.pressureRightS1,
            isLeft ? widget.tempLeftS1 : widget.tempRightS1,
            (widget.tempLeftS1 - widget.tempRightS1).abs()),
        _buildValueCard("2",
            isLeft ? widget.pressureLeftS2 : widget.pressureRightS2,
            isLeft ? widget.tempLeftS2 : widget.tempRightS2,
            (widget.tempLeftS2 - widget.tempRightS2).abs()),
        _buildValueCard("3",
            isLeft ? widget.pressureLeftS3 : widget.pressureRightS3,
            isLeft ? widget.tempLeftS3 : widget.tempRightS3,
            (widget.tempLeftS3 - widget.tempRightS3).abs()),
        _buildValueCard("4",
            isLeft ? widget.pressureLeftS4 : widget.pressureRightS4,
            isLeft ? widget.tempLeftS4 : widget.tempRightS4,
            (widget.tempLeftS4 - widget.tempRightS4).abs()),
        _buildValueCard("5",
            isLeft ? widget.pressureLeftS5 : widget.pressureRightS5,
            null,
            null),
        _buildValueCard("6",
            isLeft ? widget.pressureLeftS6 : widget.pressureRightS6,
            isLeft ? widget.tempLeftS6 : widget.tempRightS6,
            (widget.tempLeftS6 - widget.tempRightS6).abs()),
      ],
    );
  }

  Widget _buildValueCard(String number, double pressure, double? temp, double? tempDiff) {
    String formatVal(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    
    String displayValue = _displayType == "Temperature" 
        ? (temp != null ? "${formatVal(temp)} °C" : "-- °C")
        : "${formatVal(pressure)} kPa";
        
    Color valueColor;
    if (_displayType == "Temperature" && tempDiff != null) {
       if (tempDiff == 0) valueColor = Colors.green;
       else if (tempDiff < 2) valueColor = Colors.yellow.shade700;
       else valueColor = Colors.red;
    } else {
       valueColor = pressure >= 70.0 ? Colors.red : Colors.green;
    }

    if (_displayType == "Temperature" && temp == null) {
      return const SizedBox(); // Hide midfoot if it has no temperature
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.circle, size: 14, color: valueColor),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.grey.shade800, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FootImageWidget extends StatelessWidget {
  final String footSide;
  final String displayType;
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

  final double tempS1Diff;
  final double tempS2Diff;
  final double tempS3Diff;
  final double tempS4Diff;
  final double tempS6Diff;

  const FootImageWidget({
    super.key,
    this.footSide = "Right",
    required this.displayType,
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
    this.tempS1Diff = 0.0,
    this.tempS2Diff = 0.0,
    this.tempS3Diff = 0.0,
    this.tempS4Diff = 0.0,
    this.tempS6Diff = 0.0,
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
              _buildSensor(context, w, h, s1X, s1Y, pressureS1, tempS1, tempS1Diff),
              _buildSensor(context, w, h, s2X, s2Y, pressureS2, tempS2, tempS2Diff),
              _buildSensor(context, w, h, s3X, s3Y, pressureS3, tempS3, tempS3Diff),
              _buildSensor(context, w, h, s4X, s4Y, pressureS4, tempS4, tempS4Diff),
              _buildSensor(context, w, h, s5X, s5Y, pressureS5, null, null),
              _buildSensor(context, w, h, s6X, s6Y, pressureS6, tempS6, tempS6Diff),
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
    double? temp,
    double? tempDiff,
  ) {
    if (displayType == "Temperature" && temp == null) {
      return const SizedBox(); // Hide midfoot for temp view
    }

    Color circleColor;
    if (displayType == "Temperature" && tempDiff != null) {
      if (tempDiff == 0) {
        circleColor = Colors.green;
      } else if (tempDiff < 2) {
        circleColor = Colors.yellow.shade600;
      } else {
        circleColor = Colors.red;
      }
    } else {
      circleColor = pressure >= 70.0 ? Colors.red : Colors.green;
    }

    String formatVal(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    
    String displayValue = displayType == "Temperature" 
        ? (temp != null ? formatVal(temp) : "--") 
        : formatVal(pressure);

    return Positioned(
      left: (dx * w) - 25,
      top: (dy * h) - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Transform.scale(
            scaleX: footSide == "Left" ? -1.0 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (circleColor == Colors.yellow.shade600) ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
