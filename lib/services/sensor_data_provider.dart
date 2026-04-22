import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_reading.dart';
import '../models/sync_config.dart';
import 'ble_types.dart';
import 'sensor_reading_repository.dart';
import 'sync_scheduler_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TemperatureAsymmetryAlert {
  final String side;
  final String zone;
  final double difference;

  TemperatureAsymmetryAlert(this.side, this.zone, this.difference);
}

class HighPressureAlert {
  final DeviceSide side;
  final List<SensorZone> affectedZones;
  HighPressureAlert(this.side, this.affectedZones);
}

class SensorDataProvider extends ChangeNotifier {
  static const String _tag = '[SensorDataProvider]';

  final SensorReadingRepository _repository = SensorReadingRepository();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  final Map<DeviceSide, Map<SensorZone, SensorReading?>> _latestReadings = {
    DeviceSide.left: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
      SensorZone.oppositeHeel: null,
      SensorZone.oppositeBall: null,
      SensorZone.oppositeToe: null,
    },
    DeviceSide.right: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
      SensorZone.oppositeHeel: null,
      SensorZone.oppositeBall: null,
      SensorZone.oppositeToe: null,
    },
  };

  final Map<DeviceSide, BleConnectionStatus> _connectionStatus = {
    DeviceSide.left: BleConnectionStatus.connected,
    DeviceSide.right: BleConnectionStatus.connected,
  };

  final Map<DeviceSide, DateTime?> _lastUpdateTime = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };

  DateTime? lastSyncTime;

  Timer? _fetchTimer;

  SensorDataProvider() {
    _startFirebasePolling();
    SyncSchedulerService.currentConfig.addListener(_onIntervalChanged);
  }

  void _onIntervalChanged() {
    if (kDebugMode)
      print(' Fetch interval changed by user. Restarting polling.');
    _startFirebasePolling();
  }

  void _startFirebasePolling() {
    _fetchTimer?.cancel();

    // Check every minute if the system time matches the saved schedule
    _fetchTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkScheduleAndFetch();
    });

    // Optional: Also fetch once immediately on launch for UX
    _fetchFromFirebase();
  }

  void _checkScheduleAndFetch() {
    final config = SyncSchedulerService.currentConfig.value;
    final now = DateTime.now();

    // Match Hour and Minute
    if (now.hour == config.time.hour && now.minute == config.time.minute) {
      if (config.type == SyncType.weekly) {
        final days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final currentDay = days[now.weekday - 1];
        if (config.day != currentDay) return;
      } else if (config.type == SyncType.monthly) {
        if (now.day != config.date) return;
      }

      // Match found
      _fetchFromFirebase();
    }
  }

  Future<void> _fetchFromFirebase() async {
    try {
      final String timestamp = DateTime.now().toIso8601String();
      print(
        '>>> [DiaSole] [$timestamp] Attempting to fetch from Firebase RTDB at node /sensors...',
      );
      final snapshot = await _dbRef.child('sensors').get();
      print(
        '>>> [DiaSole] [$timestamp] Snapshot exists: ${snapshot.exists}, Value: ${snapshot.value}',
      );
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _processCloudData(data);
      }
    } catch (e, stack) {
      final String timestamp = DateTime.now().toIso8601String();
      print(
        '>>> [DiaSole] [$timestamp] Error fetching from Firebase: $e \\n$stack',
      );
    }
  }

  void _processCloudData(Map<String, dynamic> data) {
    bool hasUpdates = false;
    final now = DateTime.now();

    for (final sideStr in data.keys) {
      final sideEnum = sideStr.toLowerCase() == 'left'
          ? DeviceSide.left
          : DeviceSide.right;
      if (data[sideStr] is! Map) continue;
      final sideData = Map<String, dynamic>.from(data[sideStr] as Map);

      for (final zoneStr in sideData.keys) {
        final zoneData = sideData[zoneStr] is Map
            ? sideData[zoneStr] as Map
            : null;
        if (zoneData == null) continue;

        SensorZone? zoneEnum;
        if (zoneStr.toLowerCase() == 'heel') zoneEnum = SensorZone.heel;
        if (zoneStr.toLowerCase() == 'ball') zoneEnum = SensorZone.ball;
        if (zoneStr.toLowerCase() == 'toe') zoneEnum = SensorZone.toe;
        if (zoneStr.toLowerCase() == 'oppositeheel')
          zoneEnum = SensorZone.oppositeHeel;
        if (zoneStr.toLowerCase() == 'oppositeball')
          zoneEnum = SensorZone.oppositeBall;
        if (zoneStr.toLowerCase() == 'oppositetoe')
          zoneEnum = SensorZone.oppositeToe;

        if (zoneEnum != null) {
          final pressureVal = zoneData['pressure'];
          final tempVal = zoneData['temperature'];

          final p = pressureVal is num
              ? pressureVal.toDouble()
              : double.tryParse(pressureVal.toString()) ?? 0.0;
          final t = tempVal is num
              ? tempVal.toDouble()
              : double.tryParse(tempVal.toString()) ?? 0.0;

          final reading = SensorReading(
            side: sideEnum,
            zone: zoneEnum,
            pressure: p,
            temperature: t,
            timestamp: now,
          );

          _latestReadings[sideEnum]![zoneEnum] = reading;
          _repository.insertReading(reading);
          hasUpdates = true;
        }
      }
      _lastUpdateTime[sideEnum] = now;
    }

    if (hasUpdates) notifyListeners();
  }

  bool _isDataStale(DeviceSide side) {
    return false; // Display latest known data across polling intervals
  }

  List<double>? getPressures(DeviceSide side) {
    if (_isDataStale(side)) return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    return [
      _latestReadings[side]?[SensorZone.heel]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.ball]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.toe]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeHeel]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeBall]?.pressure ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeToe]?.pressure ?? 0.0,
    ];
  }

  List<double>? getTemperatures(DeviceSide side) {
    if (_isDataStale(side)) return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    return [
      _latestReadings[side]?[SensorZone.heel]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.ball]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.toe]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeHeel]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeBall]?.temperature ?? 0.0,
      _latestReadings[side]?[SensorZone.oppositeToe]?.temperature ?? 0.0,
    ];
  }

  TemperatureAsymmetryAlert? getTemperatureAsymmetryAlert() {
    final leftT = getTemperatures(DeviceSide.left);
    final rightT = getTemperatures(DeviceSide.right);
    if (leftT == null || rightT == null) return null;

    final zoneNames = [
      'Heel',
      'Ball',
      'Toe',
      'Opposite Heel',
      'Opposite Ball',
      'Opposite Toe',
    ];

    for (int i = 0; i < 6; i++) {
      if (leftT[i] <= 0 || rightT[i] <= 0) continue;
      final diff = (leftT[i] - rightT[i]).abs();
      if (diff >= 2.0) {
        String highSide = leftT[i] > rightT[i] ? "Left" : "Right";
        return TemperatureAsymmetryAlert(highSide, zoneNames[i], diff);
      }
    }
    return null;
  }

  HighPressureAlert? getHighPressureAlert({double threshold = 0.8}) {
    for (final side in [DeviceSide.left, DeviceSide.right]) {
      final p = getPressures(side);
      if (p == null) continue;
      final highZones = <SensorZone>[];
      if (p[0] > threshold) highZones.add(SensorZone.heel);
      if (p[1] > threshold) highZones.add(SensorZone.ball);
      if (p[2] > threshold) highZones.add(SensorZone.toe);
      if (p[3] > threshold) highZones.add(SensorZone.oppositeHeel);
      if (p[4] > threshold) highZones.add(SensorZone.oppositeBall);
      if (p[5] > threshold) highZones.add(SensorZone.oppositeToe);
      if (highZones.isNotEmpty) return HighPressureAlert(side, highZones);
    }
    return null;
  }

  bool isConnected(DeviceSide side) => true;
  bool get hasAnyConnection => true;
  BleConnectionStatus getConnectionStatus(DeviceSide side) =>
      _connectionStatus[side]!;

  @override
  void dispose() {
    _fetchTimer?.cancel();
    SyncSchedulerService.currentConfig.removeListener(_onIntervalChanged);
    super.dispose();
  }

  Future<List<BleScannedDevice>> scanForDevices() async => [];
  Future<void> connectToDevice(BluetoothDevice device, DeviceSide side) async {}
  Future<void> disconnectSide(DeviceSide side) async {}
}
