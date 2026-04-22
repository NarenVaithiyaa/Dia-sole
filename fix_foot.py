import re

with open('lib/widgets/foot_pressure_widget.dart', 'r') as f:
    code = f.read()

# Update RightFootWidget usages
old_left = '''                    child: RightFootWidget(
                      footSide: "Left",
                      pressureHeel: pressureLeftHeel,
                      pressureToe: pressureLeftToe,
                      pressureBall: pressureLeftBall,
                      tempHeel: tempLeftHeel,
                      tempToe: tempLeftToe,
                      tempBall: tempLeftBall,
                    ),'''
new_left = '''                    child: RightFootWidget(
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
                    ),'''
code = code.replace(old_left, new_left)

old_right = '''                  child: RightFootWidget(
                    footSide: "Right",
                    pressureHeel: pressureRightHeel,
                    pressureToe: pressureRightToe,
                    pressureBall: pressureRightBall,
                    tempHeel: tempRightHeel,
                    tempToe: tempRightToe,
                    tempBall: tempRightBall,
                  ),'''
new_right = '''                  child: RightFootWidget(
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
                  ),'''
code = code.replace(old_right, new_right)

old_vars = '''class RightFootWidget extends StatelessWidget {
  final String footSide;
  final double pressureHeel;
  final double pressureToe;
  final double pressureBall;
  final double tempHeel;
  final double tempToe;
  final double tempBall;

  const RightFootWidget({
    super.key,
    this.footSide = "Right",
    required this.pressureHeel,
    required this.pressureToe,
    required this.pressureBall,
    required this.tempHeel,
    required this.tempToe,
    required this.tempBall,
  });'''
new_vars = '''class RightFootWidget extends StatelessWidget {
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
  });'''
code = code.replace(old_vars, new_vars)

old_build = '''          final double w = constraints.maxWidth;
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
              _buildSensor(
                context,
                w,
                h,
                toeX,
                toeY,
                pressureToe,
                tempToe,
                "Toe",
              ),
              _buildSensor(
                context,
                w,
                h,
                ballX,
                ballY,
                pressureBall,
                tempBall,
                "Ball",
              ),
              _buildSensor(
                context,
                w,
                h,
                heelX,
                heelY,
                pressureHeel,
                tempHeel,
                "Heel",
              ),
            ],
          );'''
new_build = '''          final double w = constraints.maxWidth;
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
          );'''
code = code.replace(old_build, new_build)

with open('lib/widgets/foot_pressure_widget.dart', 'w') as f:
    f.write(code)

print("done")
