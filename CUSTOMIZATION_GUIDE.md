# DMS Customization Guide

This guide explains how to customize your Dentist Clinic Manager application with your clinic's branding.

## Quick Start

All customization settings are located in one file:
**`lib/config/app_config.dart`**

Simply edit this file to change your clinic's name, colors, and other settings.

---

## Available Customizations

### 1. Clinic Information

```dart
// Clinic Name - displayed throughout the app
static const String clinicName = 'Dentist Clinic Manager';

// Short clinic name for small spaces
static const String clinicShortName = 'DCM';
```

**Example:**
```dart
static const String clinicName = 'Smile Dental Clinic';
static const String clinicShortName = 'SDC';
```

---

### 2. Clinic Logo (Optional)

```dart
// Clinic Logo Path
static const String? clinicLogoPath = null;

// Show clinic logo in app bar
static const bool showLogoInAppBar = false;
```

**To add your logo:**

1. Place your logo image file in `assets/images/` folder
2. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
3. Update the config:
   ```dart
   static const String? clinicLogoPath = 'assets/images/my_clinic_logo.png';
   static const bool showLogoInAppBar = true;
   ```

---

### 3. Color Theme

#### Primary & Accent Colors

```dart
// Primary color - app bar, buttons, main UI elements
static const Color primaryColor = Color(0xFF1976D2); // Blue

// Secondary/Accent color
static const Color accentColor = Color(0xFFFF9800); // Orange
```

**Popular color combinations:**

**Professional Blue:**
```dart
static const Color primaryColor = Color(0xFF1976D2);  // Blue
static const Color accentColor = Color(0xFF03A9F4);   // Light Blue
```

**Medical Green:**
```dart
static const Color primaryColor = Color(0xFF2E7D32);  // Dark Green
static const Color accentColor = Color(0xFF66BB6A);   // Light Green
```

**Modern Purple:**
```dart
static const Color primaryColor = Color(0xFF6A1B9A);  // Purple
static const Color accentColor = Color(0xFFBA68C8);   // Light Purple
```

**Elegant Teal:**
```dart
static const Color primaryColor = Color(0xFF00796B);  // Teal
static const Color accentColor = Color(0xFF4DB6AC);   // Light Teal
```

#### Status Colors

```dart
static const Color successColor = Color(0xFF4CAF50);  // Green
static const Color warningColor = Color(0xFFF57C00);  // Orange
static const Color errorColor = Color(0xFFD32F2F);    // Red
static const Color infoColor = Color(0xFF2196F3);     // Light Blue
```

#### Dashboard Card Colors

```dart
static const Color patientCardColor = Color(0xFF1976D2);        // Blue
static const Color appointmentCardColor = Color(0xFF4CAF50);    // Green
static const Color monthlyIncomeCardColor = Color(0xFFFF9800);  // Orange
static const Color totalIncomeCardColor = Color(0xFF9C27B0);   // Purple
```

**Tip:** You can customize each dashboard card with different colors to match your brand.

---

### 4. Currency & Formatting

```dart
// Currency symbol
static const String currencySymbol = 'PKR';

// Date format
static const String dateFormat = 'MMM dd, yyyy';
```

**Currency examples:**
- `'PKR'` - Pakistani Rupee
- `'USD'` - US Dollar
- `'EUR'` - Euro
- `'GBP'` - British Pound
- `'INR'` - Indian Rupee

**Date format examples:**
- `'MMM dd, yyyy'` → Dec 04, 2025
- `'dd/MM/yyyy'` → 04/12/2025
- `'yyyy-MM-dd'` → 2025-12-04
- `'dd MMM yyyy'` → 04 Dec 2025

---

## How to Find Color Codes

### Online Color Pickers:
- **Material Design Colors:** https://materialui.co/colors/
- **Adobe Color:** https://color.adobe.com/
- **Coolors:** https://coolors.co/

### Color Format:
Colors use hex code format: `Color(0xFFRRGGBB)`

- `0xFF` - Opacity (always FF for solid colors)
- `RR` - Red value (00-FF)
- `GG` - Green value (00-FF)
- `BB` - Blue value (00-FF)

**Example:**
- `#1976D2` (web format) → `Color(0xFF1976D2)` (Flutter format)

---

## Example: Complete Customization

Here's an example for "SmileCare Dental Clinic":

```dart
class AppConfig {
  // Clinic Info
  static const String clinicName = 'SmileCare Dental Clinic';
  static const String clinicShortName = 'SmileCare';
  static const String? clinicLogoPath = 'assets/images/smilecare_logo.png';

  // Theme Colors - Teal & Orange
  static const Color primaryColor = Color(0xFF00796B);  // Teal
  static const Color accentColor = Color(0xFFFF6F00);   // Dark Orange

  // Dashboard Cards - Custom Colors
  static const Color patientCardColor = Color(0xFF00796B);       // Teal
  static const Color appointmentCardColor = Color(0xFF43A047);   // Green
  static const Color monthlyIncomeCardColor = Color(0xFFFF6F00); // Orange
  static const Color totalIncomeCardColor = Color(0xFF5E35B1);  // Deep Purple

  // Settings
  static const bool showLogoInAppBar = true;
  static const String currencySymbol = 'USD';
  static const String dateFormat = 'dd/MM/yyyy';
}
```

---

## After Making Changes

1. **Save** the `app_config.dart` file
2. **Restart** the app (hot reload may not pick up all changes)
3. Your new branding will appear throughout the application!

---

## Need Help?

If you need assistance with customization:
1. Check that color codes are in the correct format `Color(0xFFRRGGBB)`
2. Ensure the logo file path matches the actual file location
3. Make sure `pubspec.yaml` is updated if using custom assets
4. Restart the app completely after making changes

---

## What Gets Updated Automatically

When you change the config file, these elements update automatically:

✅ App title and name
✅ App bar color
✅ Navigation rail colors
✅ Dashboard card colors
✅ Quick action button colors
✅ Currency symbol everywhere
✅ Date formats in all tables
✅ Button colors and styles
✅ Overall theme consistency

No need to change multiple files - everything is centralized!
