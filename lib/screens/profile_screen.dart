import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../services/sensor_data_provider.dart';
import '../services/ble_types.dart';
import '../models/sensor_reading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<BleScannedDevice> _scannedDevices = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Profile Header
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.primaryBlue, width: 3),
                image: const DecorationImage(
                  image: NetworkImage(
                    "https://i.pravatar.cc/300",
                  ), // Placeholder avatar
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "John Doe",
              style: Theme.of(
                context,
              ).textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              "j.doe@hospital.com",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Settings Section
            _buildSectionHeader("Account Settings"),
            const SizedBox(height: 16),
            _buildSettingTile(
              Icons.person_outline,
              "Personal Information",
              () {},
            ),
            // Removed Medical ID & Stats option as requested
            _buildSettingTile(
              Icons.devices_rounded,
              "Paired Insoles",
              () => _showPairedInsolesOptions(context),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("App Preferences"),
            const SizedBox(height: 16),
            // Removed Dark Mode option as requested
            _buildSwitchTile(
              Icons.notifications_none_rounded,
              "Push Notifications",
              true,
              (val) {},
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("Data Management"),
            const SizedBox(height: 16),
            _buildSettingTile(
              Icons.file_download_outlined,
              "Export Health Data (CSV)",
              () {},
            ),
            _buildSettingTile(Icons.history_rounded, "Clear History", () {}),

            const SizedBox(height: 40),
            PrimaryButton(
              text: "Sign Out",
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "App Version 1.0.0",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showPairedInsolesOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paired Insoles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              Icons.bluetooth_searching_rounded,
              "Connect via Bluetooth",
              () {
                Navigator.pop(ctx);
                _requestBluetoothPermission(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestBluetoothPermission(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      if (!mounted) return;
      Navigator.of(context).pop();

      final scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
      final connectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
      final locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      if (scanGranted && connectGranted) {
        _scanForDevices(context);
        return;
      }

      // Some devices/OS versions still require location for BLE scan
      if ((scanGranted || connectGranted) && locationGranted) {
        _scanForDevices(context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Bluetooth permissions are required to scan for insoles. Please allow Bluetooth and Location permissions.',
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scanForDevices(BuildContext context) async {
    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Scanning for nearby insoles..."),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final provider = context.read<SensorDataProvider>();
      final devices = await provider.scanForDevices();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close scanning dialog

      setState(() {
        _scannedDevices = devices;
      });

      _showDeviceList(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close scanning dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Scan failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeviceList(BuildContext context) {
    if (_scannedDevices.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("No Devices Found"),
          content: const Text(
            "No DiaSole insoles were found. Make sure they are powered on and in pairing mode.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _scanForDevices(context);
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Insole to Connect",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._scannedDevices.map((device) {
                final sideLabel = device.identifiedSide?.name ?? "Unknown";
                final subtitle = "Signal: ${device.rssi} dBm | Side: $sideLabel";
                return _buildDeviceListTile(ctx, device, subtitle);
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceListTile(BuildContext context, BleScannedDevice device, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.bluetooth, color: AppTheme.primaryBlue),
      title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        _connectToDevice(context, device);
      },
    );
  }

  void _connectToDevice(BuildContext context, BleScannedDevice device) {
    // Determine which side to assign
    var selectedSide = device.identifiedSide;
    if (selectedSide == null) {
      // Ask user to manually select side
      _showSideSelectionDialog(context, device);
    } else {
      // Auto-assign based on identified side
      _performConnection(context, device, selectedSide);
    }
  }

  void _showSideSelectionDialog(BuildContext context, BleScannedDevice device) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select Foot Side"),
        content: Text("Which foot is ${device.name} for?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performConnection(context, device, DeviceSide.left);
            },
            child: const Text("Left Foot"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performConnection(context, device, DeviceSide.right);
            },
            child: const Text("Right Foot"),
          ),
        ],
      ),
    );
  }

  void _performConnection(BuildContext context, BleScannedDevice device, DeviceSide side) async {
    try {
      final provider = context.read<SensorDataProvider>();
      await provider.connectToDevice(device.device, side);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connected to ${device.name} as ${side.name}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.softShadow,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          trailing: Switch(
            value: value,
            activeThumbColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
