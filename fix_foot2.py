import re

with open(r'c:\Users\ELCOT\Desktop\diasole\Dia-sole\lib\widgets\foot_pressure_widget.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _selectedFoot with _selectedTab and build method
content = re.sub(
r'class _FootPressureWidgetState extends State<FootPressureWidget> \{.*?String _selectedFoot = "Right";.*?Widget build\(BuildContext context\) \{.*?return Column\(.*?_buildFootSelector\(\),.*?const SizedBox\(height: 16\),.*?Row\(.*?Expanded\(.*?flex: 5,.*?child: _buildValuesList\(\),.*?const SizedBox\(width: 8\),.*?Expanded\(.*?flex: 5,.*?child: SizedBox\(.*?height: 380,.*?child: _selectedFoot == "Left".*?Transform\.scale\(.*?scaleX: -1\.0,.*?alignment: Alignment\.center,.*?child: FootImageWidget\(.*?footSide: "Left",.*?pressureS1: widget\.pressureLeftS1,.*?pressureS2: widget\.pressureLeftS2,.*?pressureS3: widget\.pressureLeftS3,.*?pressureS4: widget\.pressureLeftS4,.*?pressureS5: widget\.pressureLeftS5,.*?pressureS6: widget\.pressureLeftS6,.*?tempS1: widget\.tempLeftS1,.*?tempS2: widget\.tempLeftS2,.*?tempS3: widget\.tempLeftS3,.*?tempS4: widget\.tempLeftS4,.*?tempS6: widget\.tempLeftS6,.*?\),.*?\).*?: FootImageWidget\(.*?footSide: "Right",.*?pressureS1: widget\.pressureRightS1,.*?pressureS2: widget\.pressureRightS2,.*?pressureS3: widget\.pressureRightS3,.*?pressureS4: widget\.pressureRightS4,.*?pressureS5: widget\.pressureRightS5,.*?pressureS6: widget\.pressureRightS6,.*?tempS1: widget\.tempRightS1,.*?tempS2: widget\.tempRightS2,.*?tempS3: widget\.tempRightS3,.*?tempS4: widget\.tempRightS4,.*?tempS6: widget\.tempRightS6,.*?\),.*?\),.*?\),.*?\],.*?\),.*?const SizedBox\(height: 24\),.*?_buildLegend\(\),.*?const SizedBox\(height: 24\),.*?_buildHealthAnalysis\(\),.*?\],.*?\);.*?\}',
r'''class _FootPressureWidgetState extends State<FootPressureWidget> {
  String _selectedTab = "Overview";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFootSelector(),
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
                      tempS1Abnormal: (widget.tempLeftS1 - widget.tempRightS1).abs() > 2.0,
                      tempS2Abnormal: (widget.tempLeftS2 - widget.tempRightS2).abs() > 2.0,
                      tempS3Abnormal: (widget.tempLeftS3 - widget.tempRightS3).abs() > 2.0,
                      tempS4Abnormal: (widget.tempLeftS4 - widget.tempRightS4).abs() > 2.0,
                      tempS6Abnormal: (widget.tempLeftS6 - widget.tempRightS6).abs() > 2.0,
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
                    tempS1Abnormal: (widget.tempLeftS1 - widget.tempRightS1).abs() > 2.0,
                    tempS2Abnormal: (widget.tempLeftS2 - widget.tempRightS2).abs() > 2.0,
                    tempS3Abnormal: (widget.tempLeftS3 - widget.tempRightS3).abs() > 2.0,
                    tempS4Abnormal: (widget.tempLeftS4 - widget.tempRightS4).abs() > 2.0,
                    tempS6Abnormal: (widget.tempLeftS6 - widget.tempRightS6).abs() > 2.0,
                  ),
          ),
        const SizedBox(height: 24),
        _buildLegend(),
        const SizedBox(height: 24),
        _buildHealthAnalysis(),
      ],
    );
  }''', content, flags=re.DOTALL)

# Replace _buildFootSelector
content = re.sub(
r'Widget _buildFootSelector\(\) \{.*?return Container\(.*?decoration: BoxDecoration\(.*?color: Colors\.grey\.shade200,.*?borderRadius: BorderRadius\.circular\(24\),.*?\),.*?padding: const EdgeInsets\.all\(4\),.*?child: Row\(.*?mainAxisSize: MainAxisSize\.min,.*?children: \[.*?_buildFootTab\("Left"\),.*?_buildFootTab\("Right"\),.*?\],.*?\),.*?\);.*?\}',
r'''Widget _buildFootSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFootTab("Overview"),
            _buildFootTab("Left"),
            _buildFootTab("Right"),
          ],
        ),
      ),
    );
  }''', content, flags=re.DOTALL)

# Replace _buildFootTab
content = re.sub(
r'Widget _buildFootTab\(String side\) \{.*?bool isSelected = _selectedFoot == side;.*?return GestureDetector\(.*?onTap: \(\) \{.*?setState\(\(\) \{.*?_selectedFoot = side;.*?\}\);.*?\},.*?child: Container\(.*?padding: const EdgeInsets\.symmetric\(horizontal: 24, vertical: 8\),.*?decoration: BoxDecoration\(.*?color: isSelected \? Colors\.white : Colors\.transparent,.*?borderRadius: BorderRadius\.circular\(20\),.*?boxShadow: isSelected.*?\[BoxShadow\(color: Colors\.black12, blurRadius: 4\)\].*?\[\],.*?\),.*?child: Text\(.*?"\$side Foot",.*?style: TextStyle\(.*?fontWeight: isSelected \? FontWeight\.bold : FontWeight\.normal,.*?color: isSelected \? Colors\.black87 : Colors\.grey\.shade600,.*?\),.*?\),.*?\),.*?\);.*?\}',
r'''Widget _buildFootTab(String title) {
    bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
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
          title == "Overview" ? "Overview" : "$title Foot",
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }''', content, flags=re.DOTALL)

# Replace _buildValuesList
content = re.sub(
r'Widget _buildValuesList\(\) \{.*?return Column\(.*?children: \[.*?_buildValueCard\("1", "Toe",.*?_selectedFoot == "Left" \? widget\.pressureLeftS1 : widget\.pressureRightS1,.*?_selectedFoot == "Left" \? widget\.tempLeftS1 : widget\.tempRightS1\),.*?_buildValueCard\("2", "Inner Ball",.*?_selectedFoot == "Left" \? widget\.pressureLeftS2 : widget\.pressureRightS2,.*?_selectedFoot == "Left" \? widget\.tempLeftS2 : widget\.tempRightS2\),.*?_buildValueCard\("3", "Mid Ball",.*?_selectedFoot == "Left" \? widget\.pressureLeftS3 : widget\.pressureRightS3,.*?_selectedFoot == "Left" \? widget\.tempLeftS3 : widget\.tempRightS3\),.*?_buildValueCard\("4", "Outer Ball",.*?_selectedFoot == "Left" \? widget\.pressureLeftS4 : widget\.pressureRightS4,.*?_selectedFoot == "Left" \? widget\.tempLeftS4 : widget\.tempRightS4\),.*?_buildValueCard\("5", "Midfoot",.*?_selectedFoot == "Left" \? widget\.pressureLeftS5 : widget\.pressureRightS5,.*?null\),.*?_buildValueCard\("6", "Heel",.*?_selectedFoot == "Left" \? widget\.pressureLeftS6 : widget\.pressureRightS6,.*?_selectedFoot == "Left" \? widget\.tempLeftS6 : widget\.tempRightS6\),.*?\],.*?\);.*?\}',
r'''Widget _buildValuesList(String side) {
    bool isLeft = side == "Left";
    return Column(
      children: [
        _buildValueCard("1", "Toe",
            isLeft ? widget.pressureLeftS1 : widget.pressureRightS1,
            isLeft ? widget.tempLeftS1 : widget.tempRightS1,
            (widget.tempLeftS1 - widget.tempRightS1).abs() > 2.0),
        _buildValueCard("2", "Inner Ball",
            isLeft ? widget.pressureLeftS2 : widget.pressureRightS2,
            isLeft ? widget.tempLeftS2 : widget.tempRightS2,
            (widget.tempLeftS2 - widget.tempRightS2).abs() > 2.0),
        _buildValueCard("3", "Mid Ball",
            isLeft ? widget.pressureLeftS3 : widget.pressureRightS3,
            isLeft ? widget.tempLeftS3 : widget.tempRightS3,
            (widget.tempLeftS3 - widget.tempRightS3).abs() > 2.0),
        _buildValueCard("4", "Outer Ball",
            isLeft ? widget.pressureLeftS4 : widget.pressureRightS4,
            isLeft ? widget.tempLeftS4 : widget.tempRightS4,
            (widget.tempLeftS4 - widget.tempRightS4).abs() > 2.0),
        _buildValueCard("5", "Midfoot",
            isLeft ? widget.pressureLeftS5 : widget.pressureRightS5,
            null,
            false),
        _buildValueCard("6", "Heel",
            isLeft ? widget.pressureLeftS6 : widget.pressureRightS6,
            isLeft ? widget.tempLeftS6 : widget.tempRightS6,
            (widget.tempLeftS6 - widget.tempRightS6).abs() > 2.0),
      ],
    );
  }''', content, flags=re.DOTALL)

# Replace _buildValueCard
content = re.sub(
r'Widget _buildValueCard\(String number, String label, double pressure, double\? temp\) \{.*?bool isHotspot = pressure >= 70\.0;.*?bool isHotTemp = temp != null && temp > 37\.5;.*?return Container\(.*?margin: const EdgeInsets\.only\(bottom: 8\),.*?padding: const EdgeInsets\.all\(8\),.*?decoration: BoxDecoration\(.*?color: Colors\.grey\.shade50,.*?borderRadius: BorderRadius\.circular\(12\),.*?border: Border\.all\(color: Colors\.grey\.shade200\),.*?\),.*?child: Row\(.*?children: \[.*?Container\(.*?width: 24,.*?height: 24,.*?decoration: BoxDecoration\(.*?color: Colors\.blue\.shade100,.*?shape: BoxShape\.circle,.*?\),.*?child: Center\(.*?child: Text\(.*?number,.*?style: TextStyle\(.*?fontWeight: FontWeight\.bold,.*?color: Colors\.blue\.shade900,.*?fontSize: 12,.*?\),.*?\),.*?\),.*?\),.*?const SizedBox\(width: 8\),.*?Expanded\(.*?child: Column\(.*?crossAxisAlignment: CrossAxisAlignment\.start,.*?children: \[.*?Text\(.*?label,.*?style: const TextStyle\(.*?fontSize: 12,.*?fontWeight: FontWeight\.w600,.*?color: Colors\.black87,.*?\),.*?maxLines: 1,.*?overflow: TextOverflow\.ellipsis,.*?\),.*?const SizedBox\(height: 2\),.*?Row\(.*?children: \[.*?Icon\(Icons\.circle, size: 8, color: isHotspot \? Colors\.red : Colors\.green\),.*?const SizedBox\(width: 4\),.*?Text\(.*?"\$\{pressure\.toStringAsFixed\(1\)\} kPa",.*?style: TextStyle\(fontSize: 10, color: Colors\.grey\.shade700\),.*?\),.*?\],.*?\),.*?if \(temp != null\).*?Row\(.*?children: \[.*?Icon\(Icons\.star, size: 8, color: isHotTemp \? Colors\.red : Colors\.orange\),.*?const SizedBox\(width: 4\),.*?Text\(.*?"\$\{temp\.toStringAsFixed\(1\)\} °C",.*?style: TextStyle\(fontSize: 10, color: Colors\.grey\.shade700\),.*?\),.*?\],.*?\),.*?\],.*?\),.*?\),.*?\],.*?\),.*?\);.*?\}',
r'''Widget _buildValueCard(String number, String label, double pressure, double? temp, bool isTempAbnormal) {
    bool isHotspot = pressure >= 70.0;

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
                      Icon(Icons.star, size: 8, color: isTempAbnormal ? Colors.red : Colors.green),
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
  }''', content, flags=re.DOTALL)

# Replace FootImageWidget constructor and fields
content = re.sub(
r'class FootImageWidget extends StatelessWidget \{.*?final String footSide;.*?final double pressureS1;.*?final double pressureS2;.*?final double pressureS3;.*?final double pressureS4;.*?final double pressureS5;.*?final double pressureS6;.*?final double tempS1;.*?final double tempS2;.*?final double tempS3;.*?final double tempS4;.*?final double tempS6;.*?const FootImageWidget\(\{.*?super\.key,.*?this\.footSide = "Right",.*?required this\.pressureS1,.*?required this\.pressureS2,.*?required this\.pressureS3,.*?required this\.pressureS4,.*?required this\.pressureS5,.*?required this\.pressureS6,.*?required this\.tempS1,.*?required this\.tempS2,.*?required this\.tempS3,.*?required this\.tempS4,.*?required this\.tempS6,.*?\}\);',
r'''class FootImageWidget extends StatelessWidget {
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

  final bool tempS1Abnormal;
  final bool tempS2Abnormal;
  final bool tempS3Abnormal;
  final bool tempS4Abnormal;
  final bool tempS6Abnormal;

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
    this.tempS1Abnormal = false,
    this.tempS2Abnormal = false,
    this.tempS3Abnormal = false,
    this.tempS4Abnormal = false,
    this.tempS6Abnormal = false,
  });''', content, flags=re.DOTALL)

# Replace sensor calls in FootImageWidget.build
content = re.sub(
r'_buildSensor\(context, w, h, s1X, s1Y, pressureS1, tempS1, "S1 \(Toe\)"\),.*?_buildSensor\(context, w, h, s2X, s2Y, pressureS2, tempS2, "S2 \(Inner Ball\)"\),.*?_buildSensor\(context, w, h, s3X, s3Y, pressureS3, tempS3, "S3 \(Mid Ball\)"\),.*?_buildSensor\(context, w, h, s4X, s4Y, pressureS4, tempS4, "S4 \(Outer Ball\)"\),.*?_buildSensor\(context, w, h, s5X, s5Y, pressureS5, null, "S5 \(Midfoot\)"\),.*?_buildSensor\(context, w, h, s6X, s6Y, pressureS6, tempS6, "S6 \(Heel\)"\),',
r'''_buildSensor(context, w, h, s1X, s1Y, pressureS1, tempS1, "S1 (Toe)", tempS1Abnormal),
              _buildSensor(context, w, h, s2X, s2Y, pressureS2, tempS2, "S2 (Inner Ball)", tempS2Abnormal),
              _buildSensor(context, w, h, s3X, s3Y, pressureS3, tempS3, "S3 (Mid Ball)", tempS3Abnormal),
              _buildSensor(context, w, h, s4X, s4Y, pressureS4, tempS4, "S4 (Outer Ball)", tempS4Abnormal),
              _buildSensor(context, w, h, s5X, s5Y, pressureS5, null, "S5 (Midfoot)", false),
              _buildSensor(context, w, h, s6X, s6Y, pressureS6, tempS6, "S6 (Heel)", tempS6Abnormal),''', content, flags=re.DOTALL)

# Replace _buildSensor implementation
content = re.sub(
r'Widget _buildSensor\(\s*BuildContext context,\s*double w,\s*double h,\s*double dx,\s*double dy,\s*double pressure,\s*double\? temp, // Nullable since S5 doesn\'t have temperature\s*String pointName,\s*\) \{.*?bool isHotspot = pressure >= 70\.0;.*?bool isHotTemp = temp != null && temp > 37\.5;.*?Color pressureColor = isHotspot \? Colors\.red : Colors\.green;.*?Color tempColor = isHotTemp \? Colors\.red : Colors\.orange;.*?return Positioned\(.*?left: \(dx \* w\) - 24,.*?// perfectly center 48x48 bounds over exact target point.*?top: \(dy \* h\) - 24,.*?child: GestureDetector\(.*?onTap: \(\) \{.*?showDialog\(.*?context: context,.*?builder: \(ctx\) => AlertDialog\(.*?shape: RoundedRectangleBorder\(.*?borderRadius: BorderRadius\.circular\(16\),.*?\),.*?title: Text\(\'\$footSide \$pointName Sensor\'\),.*?content: Column\(.*?mainAxisSize: MainAxisSize\.min,.*?crossAxisAlignment: CrossAxisAlignment\.start,.*?children: \[.*?Text\(.*?\'Pressure: \$\{pressure\.toStringAsFixed\(1\)\} kPa\',.*?style: const TextStyle\(fontSize: 16\),.*?\),.*?const SizedBox\(height: 8\),.*?if \(temp != null\).*?Text\(.*?\'Temperature: \$\{temp\.toStringAsFixed\(1\)\} °C\',.*?style: const TextStyle\(fontSize: 16\),.*?\).*?else.*?const Text\(.*?\'Temperature: N/A\',.*?style: TextStyle\(fontSize: 16, color: Colors\.grey\),.*?\),.*?\],.*?\),.*?actions: \[.*?TextButton\(.*?onPressed: \(\) => Navigator\.pop\(ctx\),.*?child: const Text\(\'Close\'\),.*?\),.*?\],.*?\),.*?\);.*?\},.*?child: SizedBox\(.*?width: 48,.*?height: 48,.*?child: Column\(.*?mainAxisSize: MainAxisSize\.min,.*?mainAxisAlignment: MainAxisAlignment\.center,.*?children: \[.*?if \(temp != null\).*?Transform\.scale\(.*?scaleX: footSide == "Left" \? -1\.0 : 1\.0,.*?child: Icon\(Icons\.star, color: tempColor, size: 14\),.*?\).*?else.*?const SizedBox\(height: 14\), // Spacer for missing temp icon.*?const SizedBox\(height: 2\),.*?Container\(.*?width: 20,.*?height: 20,.*?decoration: BoxDecoration\(.*?color: pressureColor,.*?shape: BoxShape\.circle,.*?border: Border\.all\(color: Colors\.white, width: 2\),.*?boxShadow: const \[.*?BoxShadow\(.*?color: Colors\.black26,.*?blurRadius: 2,.*?offset: Offset\(0, 1\),.*?\),.*?\],.*?\),.*?child: Center\(.*?child: Transform\.scale\(.*?scaleX: footSide == "Left" \? -1\.0 : 1\.0,.*?child: Text\(.*?pointName\.substring\(1, 2\),.*?style: const TextStyle\(.*?fontSize: 11,.*?fontWeight: FontWeight\.bold,.*?color: Colors\.white,.*?\),.*?\),.*?\),.*?\),.*?\),.*?\],.*?\),.*?\),.*?\),.*?\);.*?\}',
r'''Widget _buildSensor(
    BuildContext context,
    double w,
    double h,
    double dx,
    double dy,
    double pressure,
    double? temp,
    String pointName,
    bool isTempAbnormal,
  ) {
    bool isHotspot = pressure >= 70.0;
    Color pressureColor = isHotspot ? Colors.red : Colors.green;
    Color tempColor = isTempAbnormal ? Colors.red : Colors.green;

    return Positioned(
      left: (dx * w) - 40,
      top: (dy * h) - 24,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            const SizedBox(height: 2),
            Transform.scale(
              scaleX: footSide == "Left" ? -1.0 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 2)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: pressureColor),
                        const SizedBox(width: 4),
                        Text(
                          "${pressure.toStringAsFixed(1)}",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (temp != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 8, color: tempColor),
                            const SizedBox(width: 4),
                            Text(
                              "${temp.toStringAsFixed(1)}",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }''', content, flags=re.DOTALL)

with open(r'c:\Users\ELCOT\Desktop\diasole\Dia-sole\lib\widgets\foot_pressure_widget.dart', 'w', encoding='utf-8') as f:
    f.write(content)
