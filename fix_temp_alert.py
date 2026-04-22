import re

with open('lib/services/sensor_data_provider.dart', 'r') as f:
    text = f.read()

old_class = '''class TemperatureAsymmetryAlert {
  final double leftAvg;
  final double rightAvg;
  final double difference;
  
  // Mocks to pass the dashboard screen requirements
  List<SensorZone> get anomalousZones => leftAvg > rightAvg ? [SensorZone.heel, SensorZone.ball, SensorZone.toe] : [];
  double get maxDifference => difference;

  TemperatureAsymmetryAlert(this.leftAvg, this.rightAvg, this.difference);
}'''

new_class = '''class TemperatureAsymmetryAlert {
  final String side;
  final String zone;
  final double difference;

  TemperatureAsymmetryAlert(this.side, this.zone, this.difference);
}'''

text = text.replace(old_class, new_class)

old_get = '''  TemperatureAsymmetryAlert? getTemperatureAsymmetryAlert() {
    final leftT = getTemperatures(DeviceSide.left);
    final rightT = getTemperatures(DeviceSide.right);
    if (leftT == null || rightT == null) return null;
    final lAvg = (leftT[0] + leftT[1] + leftT[2] + leftT[3] + leftT[4] + leftT[5]) / 6;
    final rAvg = (rightT[0] + rightT[1] + rightT[2] + rightT[3] + rightT[4] + rightT[5]) / 6;
    final diff = (lAvg - rAvg).abs();
    if (diff > 2.0 && lAvg > 0 && rAvg > 0) return TemperatureAsymmetryAlert(lAvg, rAvg, diff);
    return null;
  }'''

new_get = '''  TemperatureAsymmetryAlert? getTemperatureAsymmetryAlert() {
    final leftT = getTemperatures(DeviceSide.left);
    final rightT = getTemperatures(DeviceSide.right);
    if (leftT == null || rightT == null) return null;
    
    final zoneNames = ['Heel', 'Ball', 'Toe', 'Opposite Heel', 'Opposite Ball', 'Opposite Toe'];
    
    for (int i = 0; i < 6; i++) {
        if (leftT[i] <= 0 || rightT[i] <= 0) continue;
        final diff = (leftT[i] - rightT[i]).abs();
        if (diff >= 2.0) {
            String highSide = leftT[i] > rightT[i] ? "Left" : "Right";
            return TemperatureAsymmetryAlert(highSide, zoneNames[i], diff);
        }
    }
    return null;
  }'''

text = text.replace(old_get, new_get)

# Add lastSyncTime property to SensorDataProvider
last_update_map = '''  final Map<DeviceSide, DateTime?> _lastUpdateTime = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };'''

new_last_update_map = '''  final Map<DeviceSide, DateTime?> _lastUpdateTime = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };
  
  DateTime? lastSyncTime;'''

text = text.replace(last_update_map, new_last_update_map)

old_fetch = '''  Future<void> _fetchFromFirebase() async {
    try {
      print('>>> [DiaSole] Attempting to fetch from Firebase RTDB at node /sensors...');
      final snapshot = await _dbRef.child('sensors').get();
      print('>>> [DiaSole] Snapshot exists: , Value: ');
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _processCloudData(data);
      }
    } catch (e, stack) {
      print('>>> [DiaSole] Error fetching from Firebase:  \\n');
    }
  }'''

new_fetch = '''  Future<void> _fetchFromFirebase() async {
    try {
      print('>>> [DiaSole] Attempting to fetch from Firebase RTDB at node /sensors...');
      final snapshot = await _dbRef.child('sensors').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _processCloudData(data);
        lastSyncTime = DateTime.now();
        notifyListeners();
        print(',Success of sync');
      } else {
        print(',Failure of sync');
      }
    } catch (e, stack) {
      print(',Failure of sync');
      print('>>> [DiaSole] Error fetching from Firebase:  \\n');
    }
  }'''

text = text.replace(old_fetch, new_fetch)

with open('lib/services/sensor_data_provider.dart', 'w') as f:
    f.write(text)

print("done")
