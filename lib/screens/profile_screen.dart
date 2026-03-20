import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  void _requestBluetoothPermission(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enable Bluetooth"),
        content: const Text(
          "DiaSole needs Bluetooth access to find and connect to your insoles.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Deny"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _scanForDevices(context);
            },
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }

  void _scanForDevices(BuildContext context) {
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
                Text("Scanning for nearby devices..."),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate scanning network/bluetooth delay
    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close scanning dialog
      _showDeviceList(context);
    });
  }

  void _showDeviceList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Device",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDeviceTile(
              ctx,
              "DiaSole Left Insole",
              "Signal Strength: Strong",
            ),
            _buildDeviceTile(
              ctx,
              "DiaSole Right Insole",
              "Signal Strength: Good",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, String name, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.bluetooth, color: AppTheme.primaryBlue),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connected to $name"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
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
            activeColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
