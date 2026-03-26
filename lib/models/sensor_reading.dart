import 'package:flutter/foundation.dart';

/// Represents a single pressure or temperature reading from a sensor zone
enum SensorZone {
  heel,
  ball,
  toe,
}

/// Identifies which foot/insole provided the reading
enum DeviceSide {
  left,
  right,
}

/// A single telemetry sample from one insole, one zone, containing pressure and temperature.
/// Designed for high-frequency ingestion (10 Hz) and SQLite persistence.
@immutable
class SensorReading {
  /// Which insole this reading came from (left or right)
  final DeviceSide side;

  /// Which zone on the foot (heel, ball, toe)
  final SensorZone zone;

  /// Pressure in kPa (kiloPascals); valid range 0–100
  final double pressure;

  /// Temperature in Celsius; valid range 20–45
  final double temperature;

  /// UTC timestamp when this sample was captured
  final DateTime timestamp;

  /// Signal strength (RSSI) from the BLE connection when this was read, in dBm
  final int? rssi;

  /// Whether this sample passed validation checks (range, format)
  /// Set to false for malformed or out-of-range data; don't discard, store for audit.
  final bool isValid;

  /// Optional validation error message if isValid is false
  final String? validationError;

  const SensorReading({
    required this.side,
    required this.zone,
    required this.pressure,
    required this.temperature,
    required this.timestamp,
    this.rssi,
    this.isValid = true,
    this.validationError,
  });

  /// Validate pressure and temperature ranges; return new reading with validation status.
  SensorReading validateRanges() {
    final errors = <String>[];
    if (pressure < 0 || pressure > 100) {
      errors.add('Pressure $pressure kPa out of range [0, 100]');
    }
    if (temperature < 20 || temperature > 45) {
      errors.add('Temperature $temperature °C out of range [20, 45]');
    }
    if (errors.isEmpty) {
      return SensorReading(
        side: side,
        zone: zone,
        pressure: pressure,
        temperature: temperature,
        timestamp: timestamp,
        rssi: rssi,
        isValid: true,
        validationError: null,
      );
    }
    return SensorReading(
      side: side,
      zone: zone,
      pressure: pressure,
      temperature: temperature,
      timestamp: timestamp,
      rssi: rssi,
      isValid: false,
      validationError: errors.join('; '),
    );
  }

  /// Serialize to JSON for storage or transmission
  Map<String, dynamic> toJson() {
    return {
      'side': side.name,
      'zone': zone.name,
      'pressure': pressure,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
      'rssi': rssi,
      'isValid': isValid,
      'validationError': validationError,
    };
  }

  /// Deserialize from JSON
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      side: DeviceSide.values.byName(json['side'] as String),
      zone: SensorZone.values.byName(json['zone'] as String),
      pressure: (json['pressure'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      rssi: json['rssi'] as int?,
      isValid: json['isValid'] as bool? ?? true,
      validationError: json['validationError'] as String?,
    );
  }

  @override
  String toString() =>
      'SensorReading(side: $side, zone: $zone, pressure: $pressure kPa, temp: $temperature °C, ts: $timestamp, valid: $isValid)';
}

/// Aggregate of the latest reading from each zone on one foot
@immutable
class FootTelemetry {
  final DeviceSide side;
  final SensorReading heelReading;
  final SensorReading ballReading;
  final SensorReading toeReading;

  /// Most recent timestamp across all three zones
  DateTime get latestTimestamp {
    return [
      heelReading.timestamp,
      ballReading.timestamp,
      toeReading.timestamp,
    ].reduce((a, b) => a.isAfter(b) ? a : b);
  }

  const FootTelemetry({
    required this.side,
    required this.heelReading,
    required this.ballReading,
    required this.toeReading,
  });

  /// Extract pressure values in order (heel, ball, toe) for FootPressureWidget
  List<double> getPressures() => [
        heelReading.pressure,
        ballReading.pressure,
        toeReading.pressure,
      ];

  /// Extract temperature values in order (heel, ball, toe) for FootPressureWidget
  List<double> getTemperatures() => [
        heelReading.temperature,
        ballReading.temperature,
        toeReading.temperature,
      ];

  /// Check if all zones are valid
  bool get isComplete => heelReading.isValid && ballReading.isValid && toeReading.isValid;
}
