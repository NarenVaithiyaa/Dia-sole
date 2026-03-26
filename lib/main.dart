import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/sync_scheduler_service.dart';
import 'services/sensor_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SyncSchedulerService.init();
  runApp(const DiaSoleApp());
}

class DiaSoleApp extends StatelessWidget {
  const DiaSoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorDataProvider()),
      ],
      child: MaterialApp(
        title: 'DiaSole',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
