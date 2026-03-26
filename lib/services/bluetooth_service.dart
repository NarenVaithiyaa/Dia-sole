import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_reading.dart';
import 'ble_protocol.dart';
import 'ble_types.dart';

/// Comprehensive Bluetooth service for dual-insole connection and telemetry streaming.
/// Handles scanning, pairing, connection state, characteristic subscription, and data parsing.
class DiaSoleBluetoothService {
  static const String _tag = '[BluetoothService]';
  static const Duration _reconnectDelay = Duration(seconds: 2);
  static const int _maxReconnectAttempts = 5;

  // Singleton instance
  static final DiaSoleBluetoothService _instance = DiaSoleBluetoothService._();
  factory DiaSoleBluetoothService() => _instance;
  DiaSoleBluetoothService._();

  // Parser for BLE packets
  late final BlePacketParser _parser = BleProtocol.createDefaultParser();

  // Connection state for left and right insoles
  final Map<DeviceSide, BluetoothDevice?> _connectedDevices = {
    DeviceSide.left: null,
    DeviceSide.right: null,
  };

  // Subscription state
  final Map<DeviceSide, List<StreamSubscription>> _subscriptions = {
    DeviceSide.left: [],
    DeviceSide.right: [],
  };

  // Reconnection state
  final Map<DeviceSide, int> _reconnectAttempts = {
    DeviceSide.left: 0,
    DeviceSide.right: 0,
  };

  // Controllers for exposing state and data streams
  final _connectionStateController = StreamController<BleConnectionEvent>.broadcast();
  final _sensorDataStream = StreamController<SensorReading>.broadcast();

  // Public stream accessors
  Stream<BleConnectionEvent> get connectionStateStream => _connectionStateController.stream;
  Stream<SensorReading> get sensorDataStream => _sensorDataStream.stream;

  /// Check if Bluetooth adapter is available and turned on
  static Future<bool> isBluetoothOn() async {
    if (kIsWeb) {
      return true;
    }
    if (await FlutterBluePlus.isSupported == false) {
      return false;
    }
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// Scan for nearby BLE devices and return those matching DiaSole naming convention or side markers.
  Future<List<BleScannedDevice>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) async {
    if (kIsWeb) {
      print('$_tag Scan requested on web; returning empty list.');
      return [];
    }

    try {
      print('$_tag Starting BLE scan...');
      await FlutterBluePlus.startScan(timeout: timeout);

      final devices = <BleScannedDevice>[];
      final resultStream = FlutterBluePlus.scanResults;

      await for (final results in resultStream) {
        for (final result in results) {
          final device = result.device;
          final name = device.platformName ?? 'Unknown';

          // Attempt to identify side from advertisement (extract from advertisementData)
          final manufacturerData = result.advertisementData.manufacturerData;
          final identifiedSide = BleProtocol.identifySideFromAdvertisement(
            deviceName: name,
            manufacturerData: manufacturerData,
          );

          // Include if it looks like a DiaSole device (name contains "DiaSole" or side identified)
          if (name.contains('DiaSole') || identifiedSide != null) {
            devices.add(BleScannedDevice(
              device: device,
              name: name,
              rssi: result.rssi,
              identifiedSide: identifiedSide,
            ));
            print('$_tag Found device: $name (side: ${identifiedSide?.name ?? "unknown"}), RSSI: ${result.rssi}');
          }
        }
      }

      await FlutterBluePlus.stopScan();
      print('$_tag Scan complete; found ${devices.length} DiaSole devices.');
      return devices;
    } catch (e) {
      print('$_tag Scan error: $e');
      rethrow;
    }
  }

  /// Connect to a specific device and assign it to a side (left or right).
  Future<void> connectToDevice(BluetoothDevice device, DeviceSide side) async {
    try {
      print('$_tag Connecting to ${device.platformName} as $side...');

      // Disconnect any existing connection on this side
      await disconnectSide(side);

      // Establish connection
      await device.connect(license: License.free);
      _connectedDevices[side] = device;
      _reconnectAttempts[side] = 0;

      _emitConnectionEvent(side, BleConnectionStatus.connected);
      print('$_tag Connected to ${device.platformName} as $side');

      // Discover services and subscribe to characteristics
      await _subscribeToTelemetryCharacteristics(device, side);
    } catch (e) {
      print('$_tag Connection error for $side: $e');
      _emitConnectionEvent(side, BleConnectionStatus.disconnected, error: e.toString());
      await _attemptReconnect(device, side);
    }
  }

  /// Subscribe to pressure and temperature characteristics from a device.
  Future<void> _subscribeToTelemetryCharacteristics(BluetoothDevice device, DeviceSide side) async {
    try {
      final services = await device.discoverServices();
      print('$_tag Discovered ${services.length} services on $side device');

      for (final service in services) {
        // Look for telemetry service
        if (service.uuid.toString().toUpperCase() == BleProtocol.telemetryServiceUuid.toUpperCase() ||
            service.uuid.toString().toUpperCase().contains('181a')) {
          print('$_tag Found telemetry service on $side');

          for (final characteristic in service.characteristics) {
            // Subscribe to pressure notifications
            if (characteristic.uuid.toString().toUpperCase() == BleProtocol.pressureCharacteristicUuid.toUpperCase() ||
                characteristic.uuid.toString().toUpperCase().contains('2a58')) {
              if (characteristic.properties.notify) {
                await characteristic.setNotifyValue(true);
                final sub = characteristic.onValueReceived.listen((value) {
                  _handlePressureReading(value, side);
                });
                _subscriptions[side]!.add(sub);
                print('$_tag Subscribed to pressure notifications for $side');
              }
            }

            // Subscribe to temperature notifications
            if (characteristic.uuid.toString().toUpperCase() == BleProtocol.temperatureCharacteristicUuid.toUpperCase() ||
                characteristic.uuid.toString().toUpperCase().contains('2a1c')) {
              if (characteristic.properties.notify) {
                await characteristic.setNotifyValue(true);
                final sub = characteristic.onValueReceived.listen((value) {
                  _handleTemperatureReading(value, side);
                });
                _subscriptions[side]!.add(sub);
                print('$_tag Subscribed to temperature notifications for $side');
              }
            }
          }
        }
      }
    } catch (e) {
      print('$_tag Error discovering services or subscribing on $side: $e');
      _emitConnectionEvent(side, BleConnectionStatus.error, error: e.toString());
    }
  }

  /// Handle incoming pressure characteristic value
  void _handlePressureReading(List<int> rawData, DeviceSide side) {
    try {
      // For now, use a simple round-robin zone assignment: cycle through heel, ball, toe
      final now = DateTime.now().toUtc();
      
      // Parse three pressure values (heel, ball, toe) from characteristic
      // Stub format: 6 bytes = 3 × uint16 (little-endian)
      if (rawData.length >= 6) {
        final zones = [SensorZone.heel, SensorZone.ball, SensorZone.toe];
        for (int i = 0; i < 3; i++) {
          final offset = i * 2;
          final zoneData = rawData.sublist(offset, offset + 2);
          final reading = _parser.parsePressure(zoneData, side, zones[i], now);
          if (reading != null) {
            _sensorDataStream.add(reading);
          }
        }
      }
    } catch (e) {
      print('$_tag Error handling pressure reading for $side: $e');
    }
  }

  /// Handle incoming temperature characteristic value
  void _handleTemperatureReading(List<int> rawData, DeviceSide side) {
    try {
      final now = DateTime.now().toUtc();
      
      // Parse three temperature values (heel, ball, toe) from characteristic
      // Stub format: 3 bytes = 3 × uint8
      if (rawData.length >= 3) {
        final zones = [SensorZone.heel, SensorZone.ball, SensorZone.toe];
        for (int i = 0; i < 3; i++) {
          final zoneData = [rawData[i]];
          final reading = _parser.parseTemperature(zoneData, side, zones[i], now);
          if (reading != null) {
            _sensorDataStream.add(reading);
          }
        }
      }
    } catch (e) {
      print('$_tag Error handling temperature reading for $side: $e');
    }
  }

  /// Attempt to reconnect to a device with exponential backoff
  Future<void> _attemptReconnect(BluetoothDevice device, DeviceSide side) async {
    if (_reconnectAttempts[side]! >= _maxReconnectAttempts) {
      print('$_tag Max reconnect attempts reached for $side; giving up.');
      _emitConnectionEvent(side, BleConnectionStatus.disconnected);
      return;
    }

    _reconnectAttempts[side] = _reconnectAttempts[side]! + 1;
    print('$_tag Reconnecting to $side (attempt ${_reconnectAttempts[side]})...');

    await Future.delayed(_reconnectDelay);
    try {
      await connectToDevice(device, side);
    } catch (e) {
      print('$_tag Reconnect attempt failed for $side: $e');
      await _attemptReconnect(device, side);
    }
  }

  /// Disconnect a specific side without affecting the other
  Future<void> disconnectSide(DeviceSide side) async {
    try {
      _cancelSubscriptions(side);
      final device = _connectedDevices[side];
      if (device != null) {
        await device.disconnect();
        _connectedDevices[side] = null;
        _reconnectAttempts[side] = 0;
        _emitConnectionEvent(side, BleConnectionStatus.disconnected);
        print('$_tag Disconnected from $side');
      }
    } catch (e) {
      print('$_tag Error disconnecting $side: $e');
    }
  }

  /// Cancel all subscriptions for a side
  void _cancelSubscriptions(DeviceSide side) {
    for (final sub in _subscriptions[side] ?? []) {
      sub.cancel();
    }
    _subscriptions[side] = [];
  }

  /// Emit a connection state event
  void _emitConnectionEvent(DeviceSide side, BleConnectionStatus status, {String? error}) {
    _connectionStateController.add(BleConnectionEvent(
      side: side,
      status: status,
      timestamp: DateTime.now().toUtc(),
      error: error,
    ));
  }

  /// Get current connection status for a side
  BleConnectionStatus getConnectionStatus(DeviceSide side) {
    if (_connectedDevices[side] != null) {
      return BleConnectionStatus.connected;
    }
    return BleConnectionStatus.disconnected;
  }

  /// Clean up all resources
  void dispose() {
    _cancelSubscriptions(DeviceSide.left);
    _cancelSubscriptions(DeviceSide.right);
    _connectionStateController.close();
    _sensorDataStream.close();
  }
}
