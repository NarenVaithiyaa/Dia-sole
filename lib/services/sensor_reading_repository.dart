import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import '../models/sensor_reading.dart';

/// Local SQLite repository for persisting medical telemetry data.
/// Stores all sensor readings with full fidelity for audit trail and analytics.
class SensorReadingRepository {
  static const String _dbName = 'diasole_telemetry.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'sensor_readings';

  static final SensorReadingRepository _instance = SensorReadingRepository._();
  factory SensorReadingRepository() => _instance;
  SensorReadingRepository._();

  Database? _database;

  /// Initialize the database, creating tables if needed
  Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database!;
  }

  /// Create the initial database schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        side TEXT NOT NULL,
        zone TEXT NOT NULL,
        pressure REAL NOT NULL,
        temperature REAL NOT NULL,
        timestamp TEXT NOT NULL,
        rssi INTEGER,
        is_valid INTEGER NOT NULL,
        validation_error TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // Create composite index for efficient querying by side, zone, time
    await db.execute('''
      CREATE INDEX idx_side_zone_timestamp 
      ON $_tableName (side, zone, timestamp);
    ''');

    // Create index for efficient time-range queries
    await db.execute('''
      CREATE INDEX idx_timestamp 
      ON $_tableName (timestamp);
    ''');

    print('[SensorReadingRepository] Database initialized');
  }

  /// Handle database upgrades (not used in v1, but required for future versions)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migrations here as schema evolves
    print('[SensorReadingRepository] Database upgraded from v$oldVersion to v$newVersion');
  }

  /// Insert a single sensor reading into the database
  Future<int> insertReading(SensorReading reading) async {
    final db = await getDatabase();
    return db.insert(_tableName, _readingToMap(reading));
  }

  /// Insert multiple readings in a batch (more efficient for bulk inserts)
  Future<void> insertReadingsBatch(List<SensorReading> readings) async {
    final db = await getDatabase();
    final batch = db.batch();
    for (final reading in readings) {
      batch.insert(_tableName, _readingToMap(reading));
    }
    await batch.commit();
  }

  /// Query all readings for a specific side
  Future<List<SensorReading>> getReadingsBySide(DeviceSide side) async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'side = ?',
      whereArgs: [side.name],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => _mapToReading(m)).toList();
  }

  /// Query readings for a specific side and time range
  Future<List<SensorReading>> getReadingsByTimeRange(
    DeviceSide side,
    DateTime start,
    DateTime end,
  ) async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'side = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [side.name, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => _mapToReading(m)).toList();
  }

  /// Query readings for a specific zone across all sides
  Future<List<SensorReading>> getReadingsByZone(SensorZone zone) async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'zone = ?',
      whereArgs: [zone.name],
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => _mapToReading(m)).toList();
  }

  /// Get the latest reading for a specific side and zone
  Future<SensorReading?> getLatestReading(DeviceSide side, SensorZone zone) async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'side = ? AND zone = ?',
      whereArgs: [side.name, zone.name],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapToReading(maps.first);
  }

  /// Get all invalid samples (for audit trail)
  Future<List<SensorReading>> getInvalidReadings() async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'is_valid = 0',
      orderBy: 'timestamp DESC',
    );
    return maps.map((m) => _mapToReading(m)).toList();
  }

  /// Count total readings in the database
  Future<int> getTotalReadingCount() async {
    final db = await getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get readings grouped by side for a time range (useful for analytics)
  Future<Map<DeviceSide, List<SensorReading>>> getReadingsByTimeRangeBySide(
    DateTime start,
    DateTime end,
  ) async {
    final db = await getDatabase();
    final maps = await db.query(
      _tableName,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'side ASC, timestamp ASC',
    );

    final result = <DeviceSide, List<SensorReading>>{};
    for (final map in maps) {
      final reading = _mapToReading(map);
      result.putIfAbsent(reading.side, () => []).add(reading);
    }
    return result;
  }

  /// Delete readings older than a specified number of days (for storage management)
  Future<int> deleteOlderThan(int days) async {
    final db = await getDatabase();
    final cutoffDate = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return db.delete(
      _tableName,
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
  }

  /// Clear all readings (use with caution)
  Future<int> deleteAllReadings() async {
    final db = await getDatabase();
    return db.delete(_tableName);
  }

  /// Export readings as JSON for external storage/sync
  Future<List<Map<String, dynamic>>> exportReadingsAsJson({
    DeviceSide? side,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await getDatabase();
    String where = '1 = 1';
    List<dynamic> whereArgs = [];

    if (side != null) {
      where += ' AND side = ?';
      whereArgs.add(side.name);
    }
    if (startTime != null) {
      where += ' AND timestamp >= ?';
      whereArgs.add(startTime.toIso8601String());
    }
    if (endTime != null) {
      where += ' AND timestamp <= ?';
      whereArgs.add(endTime.toIso8601String());
    }

    final maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'timestamp ASC',
    );
    return maps;
  }

  /// Convert a SensorReading to a database map
  Map<String, dynamic> _readingToMap(SensorReading reading) {
    return {
      'side': reading.side.name,
      'zone': reading.zone.name,
      'pressure': reading.pressure,
      'temperature': reading.temperature,
      'timestamp': reading.timestamp.toIso8601String(),
      'rssi': reading.rssi,
      'is_valid': reading.isValid ? 1 : 0,
      'validation_error': reading.validationError,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Convert a database map to a SensorReading
  SensorReading _mapToReading(Map<String, dynamic> map) {
    return SensorReading(
      side: DeviceSide.values.byName(map['side'] as String),
      zone: SensorZone.values.byName(map['zone'] as String),
      pressure: (map['pressure'] as num).toDouble(),
      temperature: (map['temperature'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      rssi: map['rssi'] as int?,
      isValid: (map['is_valid'] as int) == 1,
      validationError: map['validation_error'] as String?,
    );
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
