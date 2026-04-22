import re

with open('lib/screens/dashboard_screen.dart', 'r') as f:
    text = f.read()

old_vars = '''        final pressureLeftHeel = leftPressures?[0] ?? 50.0;
        final pressureLeftToe = leftPressures?[1] ?? 30.0;
        final pressureLeftBall = leftPressures?[2] ?? 40.0;
        final pressureRightHeel = rightPressures?[0] ?? 80.0;
        final pressureRightToe = rightPressures?[1] ?? 40.0;
        final pressureRightBall = rightPressures?[2] ?? 50.0;

        final tempLeftHeel = leftTemps?[0] ?? 36.5;
        final tempLeftToe = leftTemps?[1] ?? 36.6;
        final tempLeftBall = leftTemps?[2] ?? 36.6;
        final tempRightHeel = rightTemps?[0] ?? 37.0;
        final tempRightToe = rightTemps?[1] ?? 36.8;
        final tempRightBall = rightTemps?[2] ?? 36.9;'''
new_vars = '''        final pressureLeftHeel = leftPressures != null && leftPressures.isNotEmpty ? leftPressures[0] : 50.0;
        final pressureLeftBall = leftPressures != null && leftPressures.length > 1 ? leftPressures[1] : 40.0;
        final pressureLeftToe = leftPressures != null && leftPressures.length > 2 ? leftPressures[2] : 30.0;
        final pressureLeftOppositeHeel = leftPressures != null && leftPressures.length > 3 ? leftPressures[3] : 50.0;
        final pressureLeftOppositeBall = leftPressures != null && leftPressures.length > 4 ? leftPressures[4] : 40.0;
        final pressureLeftOppositeToe = leftPressures != null && leftPressures.length > 5 ? leftPressures[5] : 30.0;

        final pressureRightHeel = rightPressures != null && rightPressures.isNotEmpty ? rightPressures[0] : 80.0;
        final pressureRightBall = rightPressures != null && rightPressures.length > 1 ? rightPressures[1] : 50.0;
        final pressureRightToe = rightPressures != null && rightPressures.length > 2 ? rightPressures[2] : 40.0;
        final pressureRightOppositeHeel = rightPressures != null && rightPressures.length > 3 ? rightPressures[3] : 80.0;
        final pressureRightOppositeBall = rightPressures != null && rightPressures.length > 4 ? rightPressures[4] : 50.0;
        final pressureRightOppositeToe = rightPressures != null && rightPressures.length > 5 ? rightPressures[5] : 40.0;

        final tempLeftHeel = leftTemps != null && leftTemps.isNotEmpty ? leftTemps[0] : 36.5;
        final tempLeftBall = leftTemps != null && leftTemps.length > 1 ? leftTemps[1] : 36.6;
        final tempLeftToe = leftTemps != null && leftTemps.length > 2 ? leftTemps[2] : 36.6;
        final tempLeftOppositeHeel = leftTemps != null && leftTemps.length > 3 ? leftTemps[3] : 36.5;
        final tempLeftOppositeBall = leftTemps != null && leftTemps.length > 4 ? leftTemps[4] : 36.6;
        final tempLeftOppositeToe = leftTemps != null && leftTemps.length > 5 ? leftTemps[5] : 36.6;

        final tempRightHeel = rightTemps != null && rightTemps.isNotEmpty ? rightTemps[0] : 37.0;
        final tempRightBall = rightTemps != null && rightTemps.length > 1 ? rightTemps[1] : 36.9;
        final tempRightToe = rightTemps != null && rightTemps.length > 2 ? rightTemps[2] : 36.8;
        final tempRightOppositeHeel = rightTemps != null && rightTemps.length > 3 ? rightTemps[3] : 37.0;
        final tempRightOppositeBall = rightTemps != null && rightTemps.length > 4 ? rightTemps[4] : 36.9;
        final tempRightOppositeToe = rightTemps != null && rightTemps.length > 5 ? rightTemps[5] : 36.8;'''

text = text.replace(old_vars, new_vars)

old_widget = '''              FootPressureWidget(
                pressureLeftHeel: pressureLeftHeel,
                pressureLeftToe: pressureLeftToe,
                pressureLeftBall: pressureLeftBall,
                pressureRightHeel: pressureRightHeel,
                pressureRightToe: pressureRightToe,
                pressureRightBall: pressureRightBall,
                tempLeftHeel: tempLeftHeel,
                tempLeftToe: tempLeftToe,
                tempLeftBall: tempLeftBall,
                tempRightHeel: tempRightHeel,
                tempRightToe: tempRightToe,
                tempRightBall: tempRightBall,
              )'''
new_widget = '''              FootPressureWidget(
                pressureLeftHeel: pressureLeftHeel,
                pressureLeftToe: pressureLeftToe,
                pressureLeftBall: pressureLeftBall,
                pressureLeftOppositeHeel: pressureLeftOppositeHeel,
                pressureLeftOppositeToe: pressureLeftOppositeToe,
                pressureLeftOppositeBall: pressureLeftOppositeBall,
                pressureRightHeel: pressureRightHeel,
                pressureRightToe: pressureRightToe,
                pressureRightBall: pressureRightBall,
                pressureRightOppositeHeel: pressureRightOppositeHeel,
                pressureRightOppositeToe: pressureRightOppositeToe,
                pressureRightOppositeBall: pressureRightOppositeBall,
                tempLeftHeel: tempLeftHeel,
                tempLeftToe: tempLeftToe,
                tempLeftBall: tempLeftBall,
                tempLeftOppositeHeel: tempLeftOppositeHeel,
                tempLeftOppositeToe: tempLeftOppositeToe,
                tempLeftOppositeBall: tempLeftOppositeBall,
                tempRightHeel: tempRightHeel,
                tempRightToe: tempRightToe,
                tempRightBall: tempRightBall,
                tempRightOppositeHeel: tempRightOppositeHeel,
                tempRightOppositeToe: tempRightOppositeToe,
                tempRightOppositeBall: tempRightOppositeBall,
              )'''

text = text.replace(old_widget, new_widget)

with open('lib/screens/dashboard_screen.dart', 'w') as f:
    f.write(text)

print("done")
