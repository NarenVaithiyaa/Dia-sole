import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import '../theme/app_theme.dart';

/// Represents a single parsed log entry from Firebase /logs
class _LogEntry {
  final DateTime timestamp;
  final Map<String, Map<String, double>> sideData; // side -> zone -> pressure/temp

  _LogEntry({required this.timestamp, required this.sideData});

  double get avgPressure {
    double sum = 0;
    int count = 0;
    for (final zones in sideData.values) {
      for (final entry in zones.entries) {
        if (entry.key.endsWith('_pressure')) {
          sum += entry.value;
          count++;
        }
      }
    }
    return count > 0 ? sum / count : 0;
  }

  double get avgTemperature {
    double sum = 0;
    int count = 0;
    for (final zones in sideData.values) {
      for (final entry in zones.entries) {
        if (entry.key.endsWith('_temperature')) {
          sum += entry.value;
          count++;
        }
      }
    }
    return count > 0 ? sum / count : 0;
  }

  /// Get maximum pressure anomaly (red point) in this entry.
  /// Pressure anomaly is >= 70.0 kPa.
  double? get maxPressureAnomaly {
    double maxVal = -1;
    final zones = sideData['right'] ?? {};
    for (final entry in zones.entries) {
      if (entry.key.endsWith('_pressure')) {
        if (entry.value >= 70.0) {
          if (entry.value > maxVal) maxVal = entry.value;
        }
      }
    }
    return maxVal != -1 ? maxVal : null;
  }

  /// Get maximum temperature anomaly (red point) in this entry.
  /// Temperature anomaly is defined as a difference >= 2.0°C between corresponding zones.
  /// Returns the maximum temperature value among the anomalous zones.
  double? get maxTempAnomaly {
    double maxVal = -1;
    final zones = sideData['right'] ?? {};
    final pairs = [
      ['heel', 'oppositeHeel'],
      ['ball', 'oppositeBall'],
      ['toe', 'oppositeToe'],
    ];
    for (final pair in pairs) {
      final t1 = zones['${pair[0]}_temperature'];
      final t2 = zones['${pair[1]}_temperature'];
      if (t1 != null && t2 != null) {
        if ((t1 - t2).abs() >= 2.0) {
          final m = t1 > t2 ? t1 : t2;
          if (m > maxVal) maxVal = m;
        }
      }
    }
    return maxVal != -1 ? maxVal : null;
  }

  /// Get average pressure for a specific zone across both sides
  double getZonePressure(String zone) {
    double sum = 0;
    int count = 0;
    for (final zones in sideData.values) {
      final key = '${zone}_pressure';
      if (zones.containsKey(key)) {
        sum += zones[key]!;
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  /// Get average temperature for a specific zone across both sides
  double getZoneTemperature(String zone) {
    double sum = 0;
    int count = 0;
    for (final zones in sideData.values) {
      final key = '${zone}_temperature';
      if (zones.containsKey(key)) {
        sum += zones[key]!;
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool _isLoading = true;
  String? _errorMessage;
  List<_LogEntry> _logEntries = [];
  String _selectedTab = "Pressure";

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  Future<void> _fetchHistoricalData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String timestamp = DateTime.now().toIso8601String();
      print('');
      print('┌──────────────────────────────────────────────────────────────');
      print('│ [DiaSole] ANALYTICS — FETCHING HISTORICAL DATA');
      print('│ Timestamp : $timestamp');
      print('│ Node      : /logs');
      print('├──────────────────────────────────────────────────────────────');

      final snapshot = await _dbRef.child('logs').get();

      if (snapshot.exists && snapshot.value != null) {
        final rawData = snapshot.value;
        final entries = <_LogEntry>[];

        if (rawData is Map) {
          final logsMap = Map<String, dynamic>.from(rawData);
          print('│ Status    : ✅ ${logsMap.length} log entries found');

          for (final key in logsMap.keys) {
            final entryData = logsMap[key];
            if (entryData is! Map) continue;

            final entryMap = Map<String, dynamic>.from(entryData);

            // Parse timestamp from the entry or from the key
            DateTime entryTimestamp;
            if (entryMap.containsKey('timestamp')) {
              entryTimestamp = DateTime.tryParse(entryMap['timestamp'].toString()) ?? DateTime.now();
            } else {
              // Try to parse the key itself as a timestamp
              entryTimestamp = DateTime.tryParse(key) ?? DateTime.now();
            }

            // Parse flat data structure (p1-p6, t1-t5)
            final zoneValues = <String, double>{};
            final zones = ['heel', 'ball', 'toe', 'oppositeHeel', 'oppositeBall', 'oppositeToe'];

            for (int i = 0; i < 6; i++) {
              final pKey = 'p${i + 1}';
              final tKey = 't${i + 1}';
              final zone = zones[i];

              if (entryMap.containsKey(pKey)) {
                final p = entryMap[pKey];
                zoneValues['${zone}_pressure'] = (p is num) ? p.toDouble() : (double.tryParse(p.toString()) ?? 0.0);
              }
              if (entryMap.containsKey(tKey)) {
                final t = entryMap[tKey];
                zoneValues['${zone}_temperature'] = (t is num) ? t.toDouble() : (double.tryParse(t.toString()) ?? 0.0);
              }
            }

            if (zoneValues.isNotEmpty) {
              entries.add(_LogEntry(timestamp: entryTimestamp, sideData: {'right': zoneValues}));
            }
          }

          // Sort entries by timestamp
          entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          print('│ Parsed    : ${entries.length} valid entries');
        } else if (rawData is List) {
          // Handle list-style logs
          print('│ Status    : ✅ ${rawData.length} log entries found (list format)');
          for (int i = 0; i < rawData.length; i++) {
            final item = rawData[i];
            if (item == null || item is! Map) continue;

            final entryMap = Map<String, dynamic>.from(item);
            DateTime entryTimestamp;
            if (entryMap.containsKey('timestamp')) {
              entryTimestamp = DateTime.tryParse(entryMap['timestamp'].toString()) ?? DateTime.now();
            } else {
              entryTimestamp = DateTime.now().subtract(Duration(hours: rawData.length - i));
            }

            final zoneValues = <String, double>{};
            final zones = ['heel', 'ball', 'toe', 'oppositeHeel', 'oppositeBall', 'oppositeToe'];

            for (int j = 0; j < 6; j++) {
              final pKey = 'p${j + 1}';
              final tKey = 't${j + 1}';
              final zone = zones[j];

              if (entryMap.containsKey(pKey)) {
                final p = entryMap[pKey];
                zoneValues['${zone}_pressure'] = (p is num) ? p.toDouble() : (double.tryParse(p.toString()) ?? 0.0);
              }
              if (entryMap.containsKey(tKey)) {
                final t = entryMap[tKey];
                zoneValues['${zone}_temperature'] = (t is num) ? t.toDouble() : (double.tryParse(t.toString()) ?? 0.0);
              }
            }

            if (zoneValues.isNotEmpty) {
              entries.add(_LogEntry(timestamp: entryTimestamp, sideData: {'right': zoneValues}));
            }
          }

          entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          print('│ Parsed    : ${entries.length} valid entries');
        }

        print('└──────────────────────────────────────────────────────────────');
        print('');

        setState(() {
          _logEntries = entries;
          _isLoading = false;
        });
      } else {
        print('│ Status    : ⚠️  No data at /logs');
        print('└──────────────────────────────────────────────────────────────');
        print('');
        setState(() {
          _logEntries = [];
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print('│ Status    : ❌ ERROR');
      print('│ Error     : $e');
      print('│ Stack     : $stack');
      print('└──────────────────────────────────────────────────────────────');
      print('');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryBlue),
                    SizedBox(height: 16),
                    Text(
                      'Loading historical data from Firebase...',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : _logEntries.isEmpty
                    ? _buildEmptyState()
                    : _buildAnalyticsContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Failed to load analytics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchHistoricalData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No Historical Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'No log entries found in Firebase /logs.\nSensor data will appear here as it accumulates over time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchHistoricalData,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return RefreshIndicator(
      onRefresh: _fetchHistoricalData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Analytics",
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${_logEntries.length} historical readings from Firebase /logs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildTabSelector(),
            const SizedBox(height: 24),
            if (_selectedTab == "Pressure") ...[
              _buildSectionTitle("Monthly Pressure Anomalies"),
              const SizedBox(height: 16),
              _buildMonthlyAnomalyTrendChart("Pressure"),
              const SizedBox(height: 24),
              _buildSectionTitle("Weekly Average Pressure"),
              const SizedBox(height: 16),
              _buildWeeklyAverageChart("Pressure"),
            ] else ...[
              _buildSectionTitle("Monthly Temperature Anomalies"),
              const SizedBox(height: 16),
              _buildMonthlyAnomalyTrendChart("Temperature"),
              const SizedBox(height: 24),
              _buildSectionTitle("Weekly Average Temperature"),
              const SizedBox(height: 16),
              _buildWeeklyAverageChart("Temperature"),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle("Data Summary"),
            const SizedBox(height: 16),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Pressure")),
          Expanded(child: _buildTabButton("Temperature")),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  /// Line chart showing monthly anomaly trends
  Widget _buildMonthlyAnomalyTrendChart(String type) {
    final Map<int, double> monthlyMax = {};
    for (final entry in _logEntries) {
      double? anomaly = type == "Pressure" ? entry.maxPressureAnomaly : entry.maxTempAnomaly;
      if (anomaly != null) {
        // Cap values to prevent chart overflow
        if (type == "Pressure" && anomaly > 100.0) anomaly = 100.0;
        if (type == "Temperature" && anomaly > 42.0) anomaly = 42.0;

        final month = entry.timestamp.month;
        if (!monthlyMax.containsKey(month) || anomaly > monthlyMax[month]!) {
          monthlyMax[month] = anomaly;
        }
      }
    }

    final spots = <FlSpot>[];
    for (int i = 1; i <= 12; i++) {
      if (monthlyMax.containsKey(i)) {
        spots.add(FlSpot(i.toDouble(), monthlyMax[i]!));
      }
    }

    final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final color = type == "Pressure" ? AppTheme.primaryBlue : Colors.deepOrange;
    final maxY = type == "Pressure" ? 100.0 : 42.0;
    final minY = type == "Pressure" ? 0.0 : 30.0;

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: spots.isEmpty
          ? Center(child: Text('No $type anomalies detected', style: const TextStyle(color: AppTheme.textSecondary)))
          : LineChart(
              LineChartData(
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt() - 1;
                        if (idx < 0 || idx >= 12) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(monthLabels[idx], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 12,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
    );
  }

  /// Bar chart showing weekly averages
  Widget _buildWeeklyAverageChart(String type) {
    final Map<int, List<double>> weeklyData = {1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: []};
    for (final entry in _logEntries) {
      double val = type == "Pressure" ? entry.avgPressure : entry.avgTemperature;
      if (val > 0) {
        // Cap values to prevent chart overflow
        if (type == "Pressure" && val > 100.0) val = 100.0;
        if (type == "Temperature" && val > 42.0) val = 42.0;
        
        weeklyData[entry.timestamp.weekday]!.add(val);
      }
    }

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final color = type == "Pressure" ? AppTheme.primaryBlue : Colors.deepOrange;
    final maxY = type == "Pressure" ? 100.0 : 42.0;

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${dayLabels[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)} ${type == "Pressure" ? 'kPa' : '°C'}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(dayLabels[idx], style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 10)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final weekday = i + 1;
            final data = weeklyData[weekday]!;
            final avg = data.isEmpty ? 0.0 : data.reduce((a, b) => a + b) / data.length;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: avg,
                  color: color,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Summary card calculated from actual Firebase /logs data
  Widget _buildSummaryCard() {
    // Calculate summary statistics from real data
    double totalAvgPressure = 0;
    double totalAvgTemp = 0;
    double maxPressure = 0;
    double minTemp = double.infinity;
    double maxTemp = 0;

    if (_logEntries.isNotEmpty) {
      for (final entry in _logEntries) {
        final p = entry.avgPressure;
        final t = entry.avgTemperature;
        totalAvgPressure += p;
        if (t > 0) totalAvgTemp += t;
        if (p > maxPressure) maxPressure = p;
        if (t > 0 && t < minTemp) minTemp = t;
        if (t > maxTemp) maxTemp = t;
      }
      totalAvgPressure /= _logEntries.length;
      final tempEntries = _logEntries.where((e) => e.avgTemperature > 0).length;
      if (tempEntries > 0) totalAvgTemp /= tempEntries;
    }

    if (minTemp == double.infinity) minTemp = 0;

    // Determine time range
    String timeRange = 'N/A';
    if (_logEntries.length >= 2) {
      final first = _logEntries.first.timestamp;
      final last = _logEntries.last.timestamp;
      final diff = last.difference(first);
      if (diff.inDays > 0) {
        timeRange = '${diff.inDays} days';
      } else if (diff.inHours > 0) {
        timeRange = '${diff.inHours} hours';
      } else {
        timeRange = '${diff.inMinutes} minutes';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            Icons.compress_rounded,
            "Avg Pressure",
            '${totalAvgPressure.toStringAsFixed(1)} kPa',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.thermostat_rounded,
            "Avg Temperature",
            totalAvgTemp > 0 ? '${totalAvgTemp.toStringAsFixed(1)} °C' : 'N/A',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.trending_up_rounded,
            "Peak Pressure",
            '${maxPressure.toStringAsFixed(1)} kPa',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.thermostat_auto_rounded,
            "Temp Range",
            totalAvgTemp > 0
                ? '${minTemp.toStringAsFixed(1)}–${maxTemp.toStringAsFixed(1)} °C'
                : 'N/A',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.data_usage_rounded,
            "Total Readings",
            '${_logEntries.length}',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.schedule_rounded,
            "Time Span",
            timeRange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
