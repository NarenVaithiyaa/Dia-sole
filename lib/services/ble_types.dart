import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/sensor_reading.dart';

/// Represents the connection status of one insole
enum BleConnectionStatus {
  disconnected,
  connected,
  error,
  reconnecting,
}

/// Event emitted when connection status changes for a side
class BleConnectionEvent {
  final DeviceSide side;
  final BleConnectionStatus status;
  final DateTime timestamp;
  final String? error;

  BleConnectionEvent({
    required this.side,
    required this.status,
    required this.timestamp,
    this.error,
  });

  @override
  String toString() => 'BleConnectionEvent(side: $side, status: $status, error: $error)';
}

/// A scanned BLE device with identified side (if available)
class BleScannedDevice {
  final BluetoothDevice device;
  final String name;
  final int rssi;
  final DeviceSide? identifiedSide;

  BleScannedDevice({
    required this.device,
    required this.name,
    required this.rssi,
    required this.identifiedSide,
  });

  @override
  String toString() => 'BleScannedDevice(name: $name, side: ${identifiedSide?.name ?? "unknown"}, rssi: $rssi)';
}
