import 'package:flutter/material.dart';
import '../models/sync_config.dart';
import '../services/sync_scheduler_service.dart';
import '../theme/app_theme.dart';

class SyncCard extends StatefulWidget {
  const SyncCard({super.key});

  @override
  State<SyncCard> createState() => _SyncCardState();
}

class _SyncCardState extends State<SyncCard> {
  SyncType _selectedType = SyncType.daily;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedDay = 'Monday';
  int _selectedDate = 1;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    final config = SyncSchedulerService.currentConfig.value;
    setState(() {
      _selectedType = config.type;
      _selectedTime = config.time;
      if (config.day != null) _selectedDay = config.day!;
      if (config.date != null) _selectedDate = config.date!;
    });
  }

  Future<void> _saveConfig() async {
    final config = SyncConfig(
      type: _selectedType,
      time: _selectedTime,
      day: _selectedType == SyncType.weekly ? _selectedDay : null,
      date: _selectedType == SyncType.monthly ? _selectedDate : null,
    );

    await SyncSchedulerService.scheduleSync(config);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase Fetch Time saved successfully')),
      );
    }
  }

  String _getSummaryText() {
    final timeStr = _selectedTime.format(context);
    switch (_selectedType) {
      case SyncType.daily:
        return 'Sync everyday at $timeStr';
      case SyncType.weekly:
        return 'Sync every $_selectedDay at $timeStr';
      case SyncType.monthly:
        return 'Sync on the $_selectedDate of every month at $timeStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Sync Schedule",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Segmented Control for Type
          SegmentedButton<SyncType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: SyncType.daily, label: Text('Daily')),
              ButtonSegment(value: SyncType.weekly, label: Text('Weekly')),
              ButtonSegment(value: SyncType.monthly, label: Text('Monthly')),
            ],
            selected: {_selectedType},
            onSelectionChanged: (Set<SyncType> newSelection) {
              setState(() {
                _selectedType = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              if (_selectedType == SyncType.weekly) ...[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDay,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Day'),
                    items: _daysOfWeek.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDay = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (_selectedType == SyncType.monthly) ...[
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDate,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Date'),
                    items: List.generate(31, (index) => index + 1).map((date) {
                      return DropdownMenuItem(
                        value: date,
                        child: Text(date.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDate = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) {
                      setState(() => _selectedTime = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(_selectedTime.format(context)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            _getSummaryText(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Save Sync Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
