import re

with open('lib/services/sensor_data_provider.dart', 'r') as f:
    text = f.read()

old_fetch = '''  Future<void> _fetchFromFirebase() async {
    try {
      final snapshot = await _dbRef.child('sensors').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _processCloudData(data);
      }
    } catch (e) {
      if (kDebugMode) print(' Error fetching from Firebase: ');
    }
  }'''

new_fetch = '''  Future<void> _fetchFromFirebase() async {
    try {
      print('>>> [DiaSole] Attempting to fetch from Firebase RTDB at node /sensors...');
      final snapshot = await _dbRef.child('sensors').get();
      print('>>> [DiaSole] Snapshot exists: , Value: ');
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _processCloudData(data);
      }
    } catch (e, stack) {
      print('>>> [DiaSole] Error fetching from Firebase:  \n');
    }
  }'''

text = text.replace(old_fetch, new_fetch)

with open('lib/services/sensor_data_provider.dart', 'w') as f:
    f.write(text)

print("done")
