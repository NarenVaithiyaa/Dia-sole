import '../models/sensor_reading.dart';

/// BLE Service and Characteristic UUIDs for the DiaSole insole system.
/// These are placeholders pending firmware finalization.
/// Replace these values once hardware team provides the actual UUIDs.
abstract class BleProtocol {
  // ===========================================================================
  // Service and Characteristic UUIDs (to be replaced with actual firmware spec)
  // ===========================================================================

  /// Main telemetry service GUID where pressure/temperature characteristics live
  static const String telemetryServiceUuid = '0000181a-0000-1000-8000-00805f9b34fb'; // Placeholder

  /// Pressure characteristic UUID (notifications)
  static const String pressureCharacteristicUuid = '00002a58-0000-1000-8000-00805f9b34fb'; // Placeholder

  /// Temperature characteristic UUID (notifications)
  static const String temperatureCharacteristicUuid = '00002a1c-0000-1000-8000-00805f9b34fb'; // Placeholder

  /// Device identification service (side: left/right)
  static const String deviceInfoServiceUuid = '0000180a-0000-1000-8000-00805f9b34fb'; // Standard device info

  /// Device side characteristic (reads "L" or "R")
  static const String deviceSideCharacteristicUuid = '00002a29-0000-1000-8000-00805f9b34fb'; // Serial number field repurposed for demo

  // ===========================================================================
  // Side Identification Logic
  // ===========================================================================

  /// Extract side (left or right) from BLE advertisement manufacturer data or device name.
  /// Strategy: prefer manufacturer-specific marker, fall back to device name pattern.
  ///
  /// Returns DeviceSide.left or DeviceSide.right if identified, null if ambiguous.
  static DeviceSide? identifySideFromAdvertisement({
    required String deviceName,
    required Map<int, List<int>>? manufacturerData,
  }) {
    // Strategy 1: Check manufacturer data for side marker
    // Example: manufacturer ID 0x0059 (Nordic) with first byte 0x01 = right, 0x02 = left
    if (manufacturerData != null) {
      for (final entry in manufacturerData.entries) {
        // Currently unused, but ready for implementation when firmware spec arrives
        // final manufacturerId = entry.key;
        final data = entry.value;
        if (data.isNotEmpty) {
          // Placeholder logic: check first byte for side marker
          final sideMarker = data[0];
          if (sideMarker == 0x01) return DeviceSide.right;
          if (sideMarker == 0x02) return DeviceSide.left;
        }
      }
    }

    // Strategy 2: Fall back to device name convention
    // Expected: "DiaSole-L" (left) or "DiaSole-R" (right)
    if (deviceName.contains('left') || deviceName.contains('Left') || deviceName.contains('L')) {
      return DeviceSide.left;
    }
    if (deviceName.contains('right') || deviceName.contains('Right') || deviceName.contains('R')) {
      return DeviceSide.right;
    }

    // Ambiguous or unsupported naming
    return null;
  }

  // ===========================================================================
  // Packet Parser Interface
  // ===========================================================================

  /// Parse a raw BLE characteristic notification into a SensorReading.
  /// Implement this interface with your firmware's actual packet format.
  ///
  /// Example stub parser:
  /// ```
  /// class StubSensorParser implements BlePacketParser {
  ///   @override
  ///   SensorReading? parsePressure(List<int> data, DeviceSide side, DateTime ts) {
  ///     if (data.length < 2) return null;
  ///     final rawValue = data[0] | (data[1] << 8);
  ///     final pressure = rawValue / 100.0; // example scaling
  ///     return SensorReading(
  ///       side: side, zone: SensorZone.heel, pressure: pressure,
  ///       temperature: 36.5, timestamp: ts
  ///     );
  ///   }
  /// }
  /// ```
  static BlePacketParser createDefaultParser() {
    return StubSensorParser();
  }
}

/// Parser contract for interpreting pressure/temperature characteristic payloads.
abstract class BlePacketParser {
  /// Parse a pressure characteristic notification.
  /// Returns null if packet is undecodable.
  /// The side and zone must be inferred from the characteristic source context.
  SensorReading? parsePressure(List<int> data, DeviceSide side, SensorZone zone, DateTime timestamp);

  /// Parse a temperature characteristic notification.
  SensorReading? parseTemperature(List<int> data, DeviceSide side, SensorZone zone, DateTime timestamp);
}

/// Stub parser that simulates 3-zone samples (heel, ball, toe) from binary data.
/// Replace with real parser once firmware packet format is specified.
class StubSensorParser implements BlePacketParser {
  /// Parse 2-byte pressure value: little-endian uint16, scaled by 1/100 to get kPa.
  @override
  SensorReading? parsePressure(List<int> data, DeviceSide side, SensorZone zone, DateTime timestamp) {
    if (data.length < 2) {
      return SensorReading(
        side: side,
        zone: zone,
        pressure: 0,
        temperature: 36.5,
        timestamp: timestamp,
        isValid: false,
        validationError: 'Pressure packet too short (${data.length} < 2 bytes)',
      );
    }
    try {
      final rawValue = data[0] | (data[1] << 8);
      final pressure = rawValue / 100.0; // example: 5000 raw units = 50 kPa
      final reading = SensorReading(
        side: side,
        zone: zone,
        pressure: pressure,
        temperature: 36.5, // placeholder; temperature from separate characteristic
        timestamp: timestamp,
        isValid: true,
      );
      return reading.validateRanges();
    } catch (e) {
      return SensorReading(
        side: side,
        zone: zone,
        pressure: 0,
        temperature: 36.5,
        timestamp: timestamp,
        isValid: false,
        validationError: 'Pressure parse error: $e',
      );
    }
  }

  /// Parse 1-byte temperature value: uint8, interpreted as Celsius (offset 0).
  @override
  SensorReading? parseTemperature(List<int> data, DeviceSide side, SensorZone zone, DateTime timestamp) {
    if (data.isEmpty) {
      return SensorReading(
        side: side,
        zone: zone,
        pressure: 0,
        temperature: 36.5,
        timestamp: timestamp,
        isValid: false,
        validationError: 'Temperature packet empty',
      );
    }
    try {
      final tempRaw = data[0]; // Assuming uint8, 0–100 range mapped to 20–45 °C
      final temperature = 20.0 + (tempRaw / 255.0) * 25.0; // linear map [0, 255] -> [20, 45]
      final reading = SensorReading(
        side: side,
        zone: zone,
        pressure: 0, // placeholder; pressure from separate characteristic
        temperature: temperature,
        timestamp: timestamp,
        isValid: true,
      );
      return reading.validateRanges();
    } catch (e) {
      return SensorReading(
        side: side,
        zone: zone,
        pressure: 0,
        temperature: 36.5,
        timestamp: timestamp,
        isValid: false,
        validationError: 'Temperature parse error: $e',
      );
    }
  }
}
