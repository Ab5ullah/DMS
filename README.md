# Dentist Clinic Management System

A complete offline Flutter desktop application for managing a dentist clinic. This Windows-only application stores all data locally using SQLite and provides comprehensive dental practice management features including interactive dental charting, patient management, appointments, billing, and professional PDF invoices.

## Key Features

### 1. Interactive Dental Charting System
**The #1 feature that separates this from generic clinic software**

- **Visual Tooth Chart**: Interactive display of all 32 permanent teeth
- **FDI Tooth Numbering**: International standard (11-18, 21-28, 31-38, 41-48)
- **Color-Coded Status**: Instant visual identification of tooth conditions
  - Green: Healthy
  - Red: Decay
  - Blue: Filled
  - Purple: Root Canal Treatment (RCT)
  - Orange: Crown
  - Brown: Bridge
  - Grey: Implant
  - Black: Extracted
  - Amber: Planned Treatment
- **Per-Tooth Treatment History**: Complete record of all procedures performed on each tooth
- **Click-to-Add Treatments**: Intuitive interface - click any tooth to add or view treatments
- **Treatment Recording**:
  - 16+ common dental procedures (Amalgam, RCT, Crown, Extraction, etc.)
  - Custom procedure entry
  - Status selection with color preview
  - Date tracking
  - Cost recording
  - Clinical notes
- **Hover Effects**: Shows tooth type (Incisor, Canine, Premolar, Molar) and quadrant location
- **Recent Treatments View**: Chronological list of all dental procedures

### 2. Patient Management
- **Auto-Generated Patient IDs**: Sequential patient IDs (PAT-001, PAT-002, etc.)
- **CNIC Field**: Pakistani National ID card number support
- **Comprehensive Patient Information**:
  - Name, phone, age, gender, address
  - Medical history and allergies
  - Allergy warnings with visual indicators
- **Search Functionality**: Find patients by name or phone number
- **Direct Access to Dental Chart**: One-click access from patient list
- **Enhanced Validation**:
  - Phone number: Minimum 10 digits
  - Age: Valid range 0-150
  - CNIC: Exactly 13 digits

### 3. Login & Authentication
- Secure password-based authentication
- Default password: `1234`
- Password can be changed in Settings
- Auto-backup on app close

### 4. Dashboard
- Summary cards showing:
  - Total Patients
  - Today's Appointments
  - Monthly Income (in PKR)
  - Total Unpaid Balance
- Quick action buttons for common tasks
- Modern Material Design 3 interface
- Responsive navigation rail

### 5. Appointment Management
- Create and manage appointments
- Filter by status: All, Pending, Completed, Cancelled
- Update appointment status with color coding
- Date and time selection
- Link appointments to patients
- View appointment history

### 6. Billing & Payments
- Create billing records for treatments
- Track payments and outstanding balances
- **Professional PDF Invoices**:
  - Print or save to PDF
  - Clinic branding with configurable details
  - Patient information with ID and CNIC
  - Treatment details table
  - Payment summary with balance calculation
  - Status badges (PAID/UNPAID)
  - Auto-saves to `Documents\DentistClinicData\Invoices\`
- **Enhanced Validation**:
  - Cost must be greater than 0
  - Amount paid cannot be negative
  - Amount paid cannot exceed cost
- Filter by payment status (All, Paid, Unpaid)
- View complete payment history
- Currency: Pakistani Rupees (Rs.)

### 7. Treatment Templates
- Pre-configured common treatments with default costs:
  - Regular Checkup (Rs. 100)
  - Tooth Cleaning (Rs. 150)
  - Cavity Filling (Rs. 200)
  - Root Canal (Rs. 800)
  - Tooth Extraction (Rs. 250)
  - Dental Crown (Rs. 1,200)
  - Teeth Whitening (Rs. 500)
  - Dental Implant (Rs. 2,500)
- Add, edit, or delete custom templates
- Quick selection in billing

### 8. Reports
- View statistics for selected date ranges
- Total income, patient count, and appointment count
- **Export all data to Excel** (.xlsx format)
- Export includes:
  - All patient data with Patient IDs
  - Appointments
  - Billing records
- Export location: `Documents\DentistClinicData\clinic_data.xlsx`

### 9. Settings & Data Management
- Change login password
- **Automatic Backup**: Creates backup on app close
- **Manual Backup**: Create backups anytime
- **Restore from Backup**: Choose from timestamped backups
- Backup location: `Documents\DentistClinicData\Backups\`
- View application information
- Configurable clinic details (name, address, phone, email)

## Installation & Setup

### Prerequisites
- Flutter SDK (stable channel, version 3.0+)
- Windows 10 or later
- Git (optional)

### Steps to Run

1. **Clone or download the project**
   ```bash
   cd c:\ivhub\DMS\DMS
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d windows
   ```

4. **Build for production**
   ```bash
   flutter build windows --release
   ```

   After building, the executable will be located at:
   ```
   build\windows\x64\runner\Release\dms.exe
   ```

   You can distribute this .exe file to run the application on any Windows machine.

## Project Structure

```
lib/
├── main.dart                      # Application entry point with auto-backup
├── config/
│   └── app_config.dart            # App-wide configuration and theming
├── screens/
│   ├── login_screen.dart          # Login interface
│   ├── dashboard_screen.dart      # Main dashboard with navigation
│   ├── patient_screen.dart        # Patient management with dental chart access
│   ├── dental_chart_screen.dart   # Interactive dental charting (NEW)
│   ├── appointment_screen.dart    # Appointment management
│   ├── billing_screen.dart        # Billing and payments with PDF invoices
│   ├── report_screen.dart         # Reports and Excel export
│   └── settings_screen.dart       # Settings and backup/restore
├── models/
│   ├── patient_model.dart         # Patient data model with Patient ID & CNIC
│   ├── appointment_model.dart     # Appointment data model
│   ├── billing_model.dart         # Billing data model
│   └── tooth_treatment_model.dart # Tooth treatment with FDI numbering (NEW)
├── database/
│   └── db_helper.dart             # SQLite database helper (v4)
├── utils/
│   ├── excel_export.dart          # Excel export functionality
│   ├── backup_helper.dart         # Database backup/restore
│   └── pdf_invoice.dart           # PDF invoice generation (NEW)
└── widgets/
    ├── custom_button.dart         # Reusable button widget
    ├── custom_textfield.dart      # Reusable text field widget
    ├── summary_card.dart          # Dashboard summary card widget
    └── dental_chart_widget.dart   # Interactive dental chart widget (NEW)
```

## Database

### Location
- Database file: `Documents\DentistClinicData\clinic_data.db`
- Backups: `Documents\DentistClinicData\Backups\`
- Excel exports: `Documents\DentistClinicData\clinic_data.xlsx`
- PDF Invoices: `Documents\DentistClinicData\Invoices\`

### Tables (Database Version 4)

#### patients
- `id` (PRIMARY KEY)
- `patient_id` (UNIQUE) - Auto-generated (PAT-001, PAT-002, etc.)
- `name`, `phone`, `age`, `gender`, `address`
- `cnic` - Pakistani National ID (13 digits)
- `medical_history`, `allergies`

#### appointments
- `id` (PRIMARY KEY)
- `patient_id` (FOREIGN KEY)
- `date`, `time`, `reason`, `status`

#### billing
- `id` (PRIMARY KEY)
- `patient_id` (FOREIGN KEY)
- `treatment`, `cost`, `paid`, `date`

#### tooth_treatments (NEW)
- `id` (PRIMARY KEY)
- `patient_id` (FOREIGN KEY)
- `tooth_number` - FDI notation (11-48)
- `procedure` - Treatment name
- `status` - Tooth condition (healthy, decay, filled, rct, crown, etc.)
- `date` - Treatment date
- `notes` - Clinical notes
- `billing_id` (FOREIGN KEY, optional)
- `cost` - Treatment cost

#### treatment_templates
- `id` (PRIMARY KEY)
- `name`, `cost`, `description`

#### settings
- `id`, `password`

## Default Data

The application comes with dummy data for testing:
- 5 sample patients with Patient IDs
- 5 sample appointments
- 5 sample billing records
- 8 pre-configured treatment templates

## Usage Instructions

### First Time Login
1. Launch the application
2. Enter password: `1234`
3. Click Login

### Using the Dental Chart
1. Navigate to **Patients** screen
2. Click the **green medication icon** next to any patient
3. View the interactive dental chart with all 32 teeth
4. **Click any tooth** to:
   - Add a new treatment (select procedure, status, date, cost, notes)
   - View complete treatment history for that tooth
5. **Hover over teeth** to see tooth type and location
6. **Color-coded teeth** show current status at a glance
7. Click **Refresh** to reload after external changes

### Adding a Patient
1. Navigate to **Patients** screen
2. Click **"Add Patient"** button
3. Fill in patient information (Patient ID is auto-generated)
4. Optionally enter CNIC (13 digits with or without dashes)
5. Enter medical history and allergies
6. Click **"Add"**

### Recording a Tooth Treatment
1. Open patient's dental chart
2. Click the tooth you want to treat
3. In the dialog:
   - **Add Treatment Tab**: Select or type procedure, choose status, pick date, enter cost and notes
   - **History Tab**: View all previous treatments for that tooth
4. Click **"Save Treatment"**
5. The tooth color updates automatically

### Creating an Appointment
1. Navigate to **Appointments** screen
2. Click **"Add Appointment"** button
3. Select patient, date, time, and reason
4. Click **"Add"**
5. Update status as needed (Pending/Completed/Cancelled)

### Adding Billing Record
1. Navigate to **Billing** screen
2. Click **"Add Billing"** button
3. Select patient from dropdown
4. Enter treatment details
5. Enter cost and amount paid
6. Click **"Add"**

### Printing an Invoice
1. Navigate to **Billing** screen
2. Find the billing record
3. Click the **green print icon**
4. The invoice opens in print preview
5. Choose to print or save as PDF
6. PDF is also auto-saved to `Documents\DentistClinicData\Invoices\`

### Exporting to Excel
1. Navigate to **Reports** screen
2. Select date range (optional)
3. Click **"Export to Excel"** button
4. Find the file in `Documents\DentistClinicData\clinic_data.xlsx`
5. Open with Microsoft Excel or any spreadsheet application

### Creating a Backup
1. Navigate to **Settings** screen
2. Click **"Create Backup"** button
3. Backup will be saved with timestamp in the Backups folder
4. **Automatic backups** are created when you close the app

### Restoring from Backup
1. Navigate to **Settings** screen
2. Find the backup you want to restore in the list
3. Click **"Restore"** button
4. Confirm the action
5. Restart the application

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Database
  sqflite_common_ffi: ^2.3.0      # SQLite for Windows

  # File System
  path_provider: ^2.1.2           # System paths
  path: ^1.9.0                    # Path manipulation

  # UI Components
  provider: ^6.1.0                # State management
  fl_chart: ^0.65.0               # Charts and graphs
  file_picker: ^6.1.1             # File picking dialogs
  shared_preferences: ^2.2.2      # Local preferences
  flutter_slidable: ^3.1.0        # Slidable list items

  # Data Export/Import
  excel: ^2.1.0                   # Excel file generation
  pdf: ^3.11.1                    # PDF generation
  printing: ^5.13.2               # PDF printing and preview

  # Utilities
  intl: ^0.19.0                   # Date formatting and currency
```

## Build Information

- **Version**: 2.0.0
- **Platform**: Windows Desktop
- **Framework**: Flutter 3.x
- **Database**: SQLite (Version 4)
- **Currency**: Pakistani Rupees (Rs.)
- **Language**: English
- **Offline**: Yes (fully offline functionality)

## Key Improvements in v2.0

### What's New:
1. **Interactive Dental Charting System** - The game-changing feature
2. **Auto-Generated Patient IDs** - Professional sequential numbering
3. **CNIC Field** - Pakistani National ID support
4. **PDF Invoices** - Professional printable invoices with clinic branding
5. **Enhanced Validation** - Stricter input validation throughout
6. **Color-Coded Allergies** - Visual warnings for patient allergies
7. **Auto-Backup on Close** - Never lose data
8. **Treatment Templates** - Quick-select common treatments
9. **Improved UI/UX** - Material Design 3, better spacing, cleaner layouts

### Why Dental Charting Matters:
- **Visual Thinking**: Dentists work spatially - they need to see and click teeth
- **Professional Standard**: FDI numbering is the international dental standard
- **Complete Records**: Per-tooth history provides comprehensive patient care documentation
- **Competitive Edge**: Most low-cost Pakistani dental software lacks this feature
- **Ease of Use**: Intuitive interface requires no training

## Notes

- All data is stored locally on the Windows machine
- No internet connection required for any functionality
- Data is automatically saved to the database
- Automatic backups created on app close
- Default password should be changed after first login
- CNIC format: 12345-1234567-1 (13 digits with or without dashes)
- Patient IDs are auto-generated and cannot be changed
- Dental chart uses FDI two-digit tooth numbering system
- PDF invoices include clinic details from app configuration

## Troubleshooting

### App won't start
- Ensure Flutter is properly installed
- Run `flutter doctor` to check for issues
- Make sure you're using Flutter stable channel (3.0+)
- Check Windows version (Windows 10+ required)

### Database errors
- Check that the app has write permissions to Documents folder
- Try running as administrator
- If corrupted, restore from a backup in Settings
- Last resort: delete `Documents\DentistClinicData\clinic_data.db` to recreate

### Dental chart not loading
- Ensure patient has a valid ID
- Check database version is 4 (automatic migration should handle this)
- Try clicking Refresh button on dental chart screen
- Check for errors in console/logs

### PDF printing not working
- Ensure `printing` package is properly installed
- Try running `flutter pub get` again
- Check that you have a PDF viewer installed on Windows
- PDFs are also saved to `Documents\DentistClinicData\Invoices\` folder

### Build errors
- Run `flutter clean` followed by `flutter pub get`
- Delete `pubspec.lock` and run `flutter pub get` again
- Make sure all dependencies are compatible with Flutter 3.x
- Check that Windows development tools are installed (`flutter doctor`)

### Excel export issues
- Ensure Documents folder is accessible
- Check available disk space
- Try closing Excel if it's already open with the export file
- Run app as administrator if permission issues persist

## Technical Architecture

### State Management
- Uses `StatefulWidget` with local state management
- Database queries trigger UI rebuilds via `setState()`
- Mounted checks prevent memory leaks

### Database Design
- SQLite with proper foreign key constraints
- Versioned migrations for safe upgrades (currently v4)
- Indexed queries for fast searches
- Transaction support for data integrity

### Color Coding System
- Hex color codes stored in enum extensions
- Automatic contrast color calculation for text readability
- Consistent color scheme across dental chart and treatment lists

### PDF Generation
- Uses `pdf` package for document creation
- `printing` package for Windows native print dialog
- Professional layout with proper formatting
- Embeds clinic branding and patient details

## Security & Privacy

- All data stored locally - no cloud sync or external servers
- Password-protected access
- Automatic backups for data safety
- No analytics or telemetry
- GDPR-friendly (data never leaves the machine)

## Performance

- Lightweight SQLite database (typically < 10 MB)
- Fast queries with proper indexing
- Smooth animations and transitions
- Low memory footprint (< 200 MB RAM)
- Instant startup after first launch

## Future Enhancement Ideas

Potential features for future versions:
- X-ray image attachments per tooth
- Treatment plans with cost estimates
- Multi-chair/multi-dentist support
- Prescription printing
- Lab work tracking
- Inventory management for dental supplies
- SMS/Email appointment reminders (requires internet)
- Multi-language support (Urdu)
- Cloud backup option (optional)
- Mobile companion app
- Advanced reporting with charts and graphs
- Treatment calendar view
- Patient portal access

## Competitive Advantages

What makes this software stand out:
1. **True Dental Software** - Not just adapted clinic management
2. **Interactive Visual Interface** - Dental charting is front and center
3. **Professional Features** - PDF invoices, patient IDs, CNIC support
4. **Fully Offline** - No internet dependency
5. **Modern UI** - Material Design 3, smooth animations
6. **Pakistani Market Fit** - CNIC field, PKR currency, local needs
7. **Easy to Use** - Intuitive interface, no training required
8. **Affordable** - One-time purchase, no subscriptions
9. **Reliable** - Auto-backup, data migration, error handling
10. **Complete** - Everything needed to run a dental practice

## License

This project is provided for educational and commercial use.

## Support

For issues, questions, or feature requests, please contact the development team or create an issue in the project repository.

---

**Built with Flutter | Designed for Dentists | Made for Pakistan**
