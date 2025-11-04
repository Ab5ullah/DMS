import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';
import 'utils/backup_helper.dart';

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

class _DentistClinicAppState extends State<DentistClinicApp> with WidgetsBindingObserver {
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
    if (state == AppLifecycleState.detached || state == AppLifecycleState.paused) {
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
      title: 'Dentist Clinic Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
