import 'package:flutter/material.dart';

/// Centralized application configuration
/// Change these values to customize your clinic's branding
class AppConfig {
  // ==================== CLINIC INFORMATION ====================

  /// Clinic Name - displayed throughout the app
  static const String clinicName = 'Dentist Clinic Manager';

  /// Clinic Logo Path (optional)
  /// Place your logo in assets/images/ folder and update pubspec.yaml
  /// Example: 'assets/images/clinic_logo.png'
  static const String? clinicLogoPath = null;

  /// Short clinic name for small spaces
  static const String clinicShortName = 'DCM';

  // ==================== THEME COLORS ====================

  /// Primary color for the app
  /// This affects app bar, buttons, and main UI elements
  static const Color primaryColor = Color(0xFF1976D2); // Blue

  /// Secondary/Accent color
  static const Color accentColor = Color(0xFFFF9800); // Orange

  /// Color for success messages and positive actions
  static const Color successColor = Color(0xFF4CAF50); // Green

  /// Color for warnings and alerts
  static const Color warningColor = Color(0xFFF57C00); // Deep Orange

  /// Color for errors and negative actions
  static const Color errorColor = Color(0xFFD32F2F); // Red

  /// Color for informational elements
  static const Color infoColor = Color(0xFF2196F3); // Light Blue

  // ==================== DASHBOARD CARD COLORS ====================

  /// Total Patients card color
  static const Color patientCardColor = Color(0xFF1976D2); // Blue

  /// Today's Appointments card color
  static const Color appointmentCardColor = Color(0xFF4CAF50); // Green

  /// Monthly Income card color
  static const Color monthlyIncomeCardColor = Color(0xFFFF9800); // Orange

  /// Total Income card color
  static const Color totalIncomeCardColor = Color(0xFF9C27B0); // Purple

  // ==================== ADDITIONAL SETTINGS ====================

  /// Show clinic logo in app bar
  static const bool showLogoInAppBar = false;

  /// Currency symbol
  static const String currencySymbol = 'PKR';

  /// Date format (examples: 'MMM dd, yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd')
  static const String dateFormat = 'MMM dd, yyyy';

  // ==================== THEME GENERATION ====================

  /// Generate light theme based on primary color
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  /// Get color shade variations
  static MaterialColor getPrimaryMaterialColor() {
    return MaterialColor(
      primaryColor.value,
      <int, Color>{
        50: primaryColor.withOpacity(0.1),
        100: primaryColor.withOpacity(0.2),
        200: primaryColor.withOpacity(0.3),
        300: primaryColor.withOpacity(0.4),
        400: primaryColor.withOpacity(0.6),
        500: primaryColor,
        600: primaryColor.withOpacity(0.8),
        700: primaryColor.withOpacity(0.9),
        800: primaryColor.withOpacity(0.95),
        900: primaryColor,
      },
    );
  }
}
