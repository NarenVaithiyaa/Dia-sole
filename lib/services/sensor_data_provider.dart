import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_reading.dart';
import 'bluetooth_service.dart';
import 'ble_types.dart';
import 'sensor_reading_repository.dart';

/// State-management provider for sensor telemetry from both insoles.
/// Buffers the latest reading for each zone on each side,
/// and exposes high-level health flags for UI consumption.
class SensorDataProvider extends ChangeNotifier {
  static const String _tag = '[SensorDataProvider]';

  // Persistence layer
  final SensorReadingRepository _repository = SensorReadingRepository();

  // Latest sensor readings by side and zone
  final Map<DeviceSide, Map<SensorZone, SensorReading?>> _latestReadings = {
    DeviceSide.left: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
    },
    DeviceSide.right: {
      SensorZone.heel: null,
      SensorZone.ball: null,
      SensorZone.toe: null,
    },
  };

  // Connection state for each side
  final Map<DeviceSide, BleConnectionStatus> _connectionStatus = {
    DeviceSide.left: BleConnectionStatus.disconnected,
    DeviceSide.right: BleConnectionStatus.disconnected,
  };

  // Last update timestamp per side
  final Map<DeviceSide, DateTime?> _lastUpdateTime = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };

  // Subscription management
  late StreamSubscription<SensorReading> _dataSubscription;
  late StreamSubscription<BleConnectionEvent> _connectionSubscription;

  final DiaSoleBluetoothService _bluetoothService = DiaSoleBluetoothService();

  SensorDataProvider() {
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    // Listen to sensor data stream
    _dataSubscription = _bluetoothService.sensorDataStream.listen(
      (reading) {
        _handleNewReading(reading);
      },
      onError: (error) {
        print('$_tag Data stream error: $error');
      },
    );

    // Listen to connection state stream
    _connectionSubscription = _bluetoothService.connectionStateStream.listen(
      (event) {
        _handleConnectionEvent(event);
      },
      onError: (error) {
        print('$_tag Connection stream error: $error');
      },
    );

    print('$_tag Subscriptions initialized');
  }

  void _handleNewReading(SensorReading reading) {
    _latestReadings[reading.side]![reading.zone] = reading;
    _lastUpdateTime[reading.side] = reading.timestamp;
    
    if (!reading.isValid) {
      print('$_tag Invalid reading received: ${reading.validationError}');
    }

    // Persist to local SQLite database
    _repository.insertReading(reading).catchError((error) {
      print('$_tag Error persisting reading: $error');
      return 0; // Return a default value on error
    });

    notifyListeners();
  }

  void _handleConnectionEvent(BleConnectionEvent event) {
    _connectionStatus[event.side] = event.status;
    
    if (event.error != null) {
      print('$_tag Connection error for ${event.side}: ${event.error}');
    }

    notifyListeners();
  }

  // ==========================================================================
  // Public accessors for UI
  // ==========================================================================

  /// Get the latest valid complete foot reading (all three zones) for a side
  FootTelemetry? getFootTelemetry(DeviceSide side) {
    final readings = _latestReadings[side]!;
    final heel = readings[SensorZone.heel];
    final ball = readings[SensorZone.ball];
    final toe = readings[SensorZone.toe];

    if (heel == null || ball == null || toe == null) {
      return null;
    }

    if (!heel.isValid || !ball.isValid || !toe.isValid) {
      return null;
    }

    return FootTelemetry(
      side: side,
      heelReading: heel,
      ballReading: ball,
      toeReading: toe,
    );
  }

  /// Get pressure values for a side (heel, ball, toe) or null if incomplete
  List<double>? getPressures(DeviceSide side) {
    final telemetry = getFootTelemetry(side);
    return telemetry?.getPressures();
  }

  /// Get temperature values for a side (heel, ball, toe) or null if incomplete
  List<double>? getTemperatures(DeviceSide side) {
    final telemetry = getFootTelemetry(side);
    return telemetry?.getTemperatures();
  }

  /// Get connection status for a side
  BleConnectionStatus getConnectionStatus(DeviceSide side) {
    return _connectionStatus[side] ?? BleConnectionStatus.disconnected;
  }

  /// Check if both sides are connected
  bool get areBothSidesConnected {
    return _connectionStatus[DeviceSide.left] == BleConnectionStatus.connected &&
        _connectionStatus[DeviceSide.right] == BleConnectionStatus.connected;
  }

  /// Check if at least one side is connected
  bool get isAnyConnected {
    return _connectionStatus[DeviceSide.left] == BleConnectionStatus.connected ||
        _connectionStatus[DeviceSide.right] == BleConnectionStatus.connected;
  }

  /// Get latest reading for a specific zone on a side
  SensorReading? getLatestReading(DeviceSide side, SensorZone zone) {
    return _latestReadings[side]![zone];
  }

  /// Get last update time for a side
  DateTime? getLastUpdateTime(DeviceSide side) {
    return _lastUpdateTime[side];
  }

  /// Detect temperature asymmetry between corresponding zones (left vs right)
  TemperatureAsymmetryAlert? getTemperatureAsymmetryAlert() {
    final leftTelemetry = getFootTelemetry(DeviceSide.left);
    final rightTelemetry = getFootTelemetry(DeviceSide.right);

    if (leftTelemetry == null || rightTelemetry == null) {
      return null;
    }

    final diffs = <String, double>{
      'heel': (leftTelemetry.heelReading.temperature - rightTelemetry.heelReading.temperature).abs(),
      'ball': (leftTelemetry.ballReading.temperature - rightTelemetry.ballReading.temperature).abs(),
      'toe': (leftTelemetry.toeReading.temperature - rightTelemetry.toeReading.temperature).abs(),
    };

    // Alert if any zone differs by > 2°C
    final anomalies = diffs.entries.where((e) => e.value > 2.0).toList();
    if (anomalies.isNotEmpty) {
      return TemperatureAsymmetryAlert(
        anomalousZones: anomalies.map((e) => e.key).toList(),
        maxDifference: anomalies.map((e) => e.value).reduce((a, b) => a > b ? a : b),
      );
    }

    return null;
  }

  /// Get high-pressure alert if any zone exceeds threshold (example: 0.8 normalized)
  HighPressureAlert? getHighPressureAlert({double threshold = 0.8}) {
    final alerts = <String>[];

    for (final side in [DeviceSide.left, DeviceSide.right]) {
      final presures = getPressures(side);
      if (presures != null) {
        // Normalize to [0, 1] assuming max 100 kPa
        final normalized = presures.map((p) => p / 100.0).toList();
        for (int i = 0; i < normalized.length; i++) {
          if (normalized[i] > threshold) {
            final zones = ['heel', 'ball', 'toe'];
            alerts.add('${side.name}_${zones[i]}');
          }
        }
      }
    }

    if (alerts.isNotEmpty) {
      return HighPressureAlert(affectedZones: alerts);
    }

    return null;
  }

  // ==========================================================================
  // Public control methods for UI to interact with Bluetooth service
  // ==========================================================================

  /// Start scanning for nearby BLE devices
  Future<List<BleScannedDevice>> scanForDevices() async {
    final devices = await _bluetoothService.scanForDevices();
    print('$_tag Scan complete; found ${devices.length} devices');
    return devices;
  }

  /// Connect to a device and assign it to a side
  Future<void> connectToDevice(BluetoothDevice device, DeviceSide side) async {
    print('$_tag Connecting device to $side...');
    await _bluetoothService.connectToDevice(device, side);
    notifyListeners();
  }

  /// Disconnect a specific side
  Future<void> disconnectSide(DeviceSide side) async {
    await _bluetoothService.disconnectSide(side);
    notifyListeners();
  }

  /// Clear all stored readings (e.g., on user reset)
  void clearReadings() {
    for (final side in [DeviceSide.left, DeviceSide.right]) {
      for (final zone in [SensorZone.heel, SensorZone.ball, SensorZone.toe]) {
        _latestReadings[side]![zone] = null;
      }
      _lastUpdateTime[side] = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    _connectionSubscription.cancel();
    _bluetoothService.dispose();
    _repository.close();
    super.dispose();
  }
}

/// Alert data for temperature asymmetry between feet
class TemperatureAsymmetryAlert {
  final List<String> anomalousZones;
  final double maxDifference;

  TemperatureAsymmetryAlert({
    required this.anomalousZones,
    required this.maxDifference,
  });

  @override
  String toString() =>
      'TemperatureAsymmetryAlert(zones: ${anomalousZones.join(", ")}, maxDiff: ${maxDifference.toStringAsFixed(1)}°C)';
}

/// Alert data for high pressure detection
class HighPressureAlert {
  final List<String> affectedZones;

  HighPressureAlert({required this.affectedZones});

  @override
  String toString() => 'HighPressureAlert(zones: ${affectedZones.join(", ")})';
}
