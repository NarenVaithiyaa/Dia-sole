import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_config.dart';
import 'package:flutter/material.dart';

class SyncSchedulerService {
  static const String configStorageKey = 'syncConfig_v2';
  static final ValueNotifier<SyncConfig> currentConfig = ValueNotifier<SyncConfig>(SyncConfig(type: SyncType.daily, time: const TimeOfDay(hour: 0, minute: 0)));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(configStorageKey);
    if (data != null) {
      try {
        currentConfig.value = SyncConfig.fromJson(jsonDecode(data));
      } catch (e) {
        if (kDebugMode) print('Error parsing sync config: $e');
      }
    }
  }

  static Future<void> scheduleSync(SyncConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(configStorageKey, jsonEncode(config.toJson()));
    currentConfig.value = config;
  }

  static Future<SyncConfig?> getSavedConfig() async {
    return currentConfig.value;
  }
}
