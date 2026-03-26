import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/sync_config.dart';
import '../models/sensor_reading.dart';
import 'sensor_reading_repository.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("[SyncSchedulerService] Background sync task triggered: $task");

    try {
      // Get the repository and check for readings to sync
      final repository = SensorReadingRepository();
      final readingCount = await repository.getTotalReadingCount();
      print("[SyncSchedulerService] Found $readingCount readings to sync");

      if (readingCount > 0) {
        // Export recent readings for sync
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final readings = await repository.getReadingsByTimeRange(
          DeviceSide.left,
          yesterday,
          DateTime.now(),
        );
        print("[SyncSchedulerService] Exporting ${readings.length} left-foot readings from last 24h");

        // In a real app, you would upload `readings` to a backend server here.
        // For now, we just log the export.
        // final json = readings.map((r) => r.toJson()).toList();
        // await uploadToBackend(json);
      }

      print("[SyncSchedulerService] Sync task completed successfully");
      return Future.value(true);
    } catch (e) {
      print("[SyncSchedulerService] Sync task error: $e");
      return Future.value(false);
    }
  });
}

class SyncSchedulerService {
  static const String syncTaskKey = "com.diasole.syncTask";
  static const String configStorageKey = "syncConfig";

  static Future<void> init() async {
    if (kIsWeb) return;
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> scheduleSync(SyncConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(configStorageKey, jsonEncode(config.toJson()));

    if (kIsWeb) return;

    await Workmanager().cancelByUniqueName(syncTaskKey);

    Duration frequency;
    switch (config.type) {
      case SyncType.daily:
        frequency = const Duration(days: 1);
        break;
      case SyncType.weekly:
        frequency = const Duration(days: 7);
        break;
      case SyncType.monthly:
        frequency = const Duration(days: 30);
        break;
    }

    // Register a periodic task
    await Workmanager().registerPeriodicTask(
      syncTaskKey,
      "syncTaskName",
      frequency: frequency,
    );
  }

  static Future<SyncConfig?> getSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(configStorageKey);
    if (data != null) {
      return SyncConfig.fromJson(jsonDecode(data));
    }
    return null;
  }
}
