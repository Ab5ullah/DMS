import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';
import 'utils/backup_helper.dart';
import 'config/app_config.dart';

void main() {
  // Initialize FFI for Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const DentistClinicApp());
}

class DentistClinicApp extends StatefulWidget {
  const DentistClinicApp({super.key});

  @override
  State<DentistClinicApp> createState() => _DentistClinicAppState();
}

class _DentistClinicAppState extends State<DentistClinicApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // Create auto-backup when app is closing or pausing
      _createAutoBackup();
    }
  }

  Future<void> _createAutoBackup() async {
    try {
      await BackupHelper.backupDatabase();
      debugPrint('Auto-backup created successfully');
    } catch (e) {
      debugPrint('Auto-backup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.clinicName,
      debugShowCheckedModeBanner: false,
      theme: AppConfig.lightTheme,
      home: const LoginScreen(),
    );
  }
}
