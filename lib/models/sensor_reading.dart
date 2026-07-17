import 'package:flutter/foundation.dart';

/// Represents a single pressure or temperature reading from a sensor zone
enum SensorZone { s1, s2, s3, s4, s5, s6 }

/// Identifies which foot/insole provided the reading
enum DeviceSide { left, right }

/// A single telemetry sample from one insole, one zone, containing pressure and temperature.
/// Designed for high-frequency ingestion (10 Hz) and SQLite persistence.
@immutable
class SensorReading {
  /// Which insole this reading came from (left or right)
  final DeviceSide side;

  /// Which zone on the foot (s1 to s6)
  final SensorZone zone;

  /// Pressure in kPa (kiloPascals); valid range 0–100
  final double pressure;

  /// Temperature in Celsius; valid range 20–45. S5 might not have temperature, in which case it is 0.0 or ignored.
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
    // S5 has no temperature, so we might skip temperature validation for S5 if we want, or just let it be.
    // Assuming 0.0 is used for 'no temperature' on s5, we should ignore validating temperature if it's s5 and temperature is 0.0.
    if (zone != SensorZone.s5 && (temperature < 20 || temperature > 45)) {
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
