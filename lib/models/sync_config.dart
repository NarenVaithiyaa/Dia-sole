import 'package:flutter/material.dart';

enum SyncType { daily, weekly, monthly }

class SyncConfig {
  SyncType type;
  TimeOfDay time;
  String? day;
  int? date;

  SyncConfig({required this.type, required this.time, this.day, this.date});

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
      'day': day,
      'date': date,
    };
  }

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return SyncConfig(
      type: SyncType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncType.daily,
      ),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      day: json['day'],
      date: json['date'],
    );
  }
}
