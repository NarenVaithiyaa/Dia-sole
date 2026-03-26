import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/foot_pressure_widget.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/sync_card.dart';
import '../models/sensor_reading.dart';
import '../services/sensor_data_provider.dart';
import 'analytics_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildBody(),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_navIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const AnalyticsScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          24,
          24,
          100,
        ), // Bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            const SyncCard(),
            const SizedBox(height: 24),
            _buildActiveAnalysisCard(),
            const SizedBox(height: 24),
            _buildMedicalInsightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.accessibility_new_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "DiaSole",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.battery_charging_full_rounded,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 4),
            const Text(
              "78%",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.bluetooth_connected_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAnalysisCard() {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        final leftPressures = provider.getPressures(DeviceSide.left);
        final leftTemps = provider.getTemperatures(DeviceSide.left);
        final rightPressures = provider.getPressures(DeviceSide.right);
        final rightTemps = provider.getTemperatures(DeviceSide.right);

        // Use live values if available, fall back to defaults
        final pressureLeftHeel = leftPressures?[0] ?? 50.0;
        final pressureLeftToe = leftPressures?[1] ?? 30.0;
        final pressureLeftBall = leftPressures?[2] ?? 40.0;
        final pressureRightHeel = rightPressures?[0] ?? 80.0;
        final pressureRightToe = rightPressures?[1] ?? 40.0;
        final pressureRightBall = rightPressures?[2] ?? 50.0;

        final tempLeftHeel = leftTemps?[0] ?? 36.5;
        final tempLeftToe = leftTemps?[1] ?? 36.6;
        final tempLeftBall = leftTemps?[2] ?? 36.6;
        final tempRightHeel = rightTemps?[0] ?? 37.0;
        final tempRightToe = rightTemps?[1] ?? 36.8;
        final tempRightBall = rightTemps?[2] ?? 36.9;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "REAL-TIME PRESSURE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          "Active Foot Health Analysis",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FootPressureWidget(
                pressureLeftHeel: pressureLeftHeel,
                pressureLeftToe: pressureLeftToe,
                pressureLeftBall: pressureLeftBall,
                pressureRightHeel: pressureRightHeel,
                pressureRightToe: pressureRightToe,
                pressureRightBall: pressureRightBall,
                tempLeftHeel: tempLeftHeel,
                tempLeftToe: tempLeftToe,
                tempLeftBall: tempLeftBall,
                tempRightHeel: tempRightHeel,
                tempRightToe: tempRightToe,
                tempRightBall: tempRightBall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicalInsightCard() {
    return Consumer<SensorDataProvider>(
      builder: (context, provider, child) {
        // Check for temperature asymmetry or high pressure alerts
        final tempAlert = provider.getTemperatureAsymmetryAlert();
        final pressureAlert = provider.getHighPressureAlert(threshold: 0.75);

        String alertText = "No anomalies detected. Foot Health: Normal";
        Color alertColor = Colors.green;

        if (tempAlert != null) {
          alertText = "Temperature asymmetry detected in ${tempAlert.anomalousZones.join(", ")}. "
              "Max difference: ${tempAlert.maxDifference.toStringAsFixed(1)}°C";
          alertColor = Colors.orange;
        } else if (pressureAlert != null) {
          alertText = "High pressure detected on ${pressureAlert.affectedZones.join(", ")}. "
              "Consider adjusting your stride or checking insole alignment.";
          alertColor = Colors.red;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: alertColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: alertColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: alertColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Medical Insight",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: alertColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alertText,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
