# Dentist Clinic Management System

A complete offline Flutter desktop application for managing a dentist clinic. This Windows-only application stores all data locally using SQLite and provides Excel export functionality.

## Features

### 1. Login Screen
- Secure password-based authentication
- Default password: `1234`
- Password can be changed in Settings

### 2. Dashboard  
- Summary cards showing:
  - Total Patients
  - Today's Appointments
  - Monthly Income
- Quick action buttons for common tasks
- Responsive navigation menu

### 3. Patient Management
- Add, edit, and delete patient records
- Patient information includes:
  - Name, phone, age, gender, address
  - Medical history and allergies
- Search patients by name or phone number
- View patient visit history

### 4. Appointment Management
- Create and manage appointments
- Filter by status: All, Pending, Completed, Cancelled
- Update appointment status
- Calendar view for scheduling
- Link appointments to patients

### 5. Billing & Payments
- Create billing records for treatments
- Track payments and outstanding balances
- Filter by payment status (All, Paid, Unpaid)
- View complete payment history

### 6. Reports
- View statistics for selected date ranges
- Total income, patient count, and appointment count
- Export all data to Excel (.xlsx format)
- Export location: `Documents\DentistClinicData\clinic_data.xlsx`

### 7. Settings
- Change login password
- Backup database
- Restore from previous backups
- View application information

## Installation & Setup

### Prerequisites
- Flutter SDK (stable channel)
- Windows 10 or later
- Git (optional)

### Steps to Run

1. **Clone or download the project**
   ```bash
   cd "d:\Flutter Projects\dms"
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
   flutter build windows
   ```

   After building, the executable will be located at:
   ```
   build\windows\x64\runner\Release\dms.exe
   ```

   You can double-click this .exe file to run the application.

## Project Structure

```
lib/
├── main.dart                      # Application entry point
├── screens/
│   ├── login_screen.dart          # Login interface
│   ├── dashboard_screen.dart      # Main dashboard with navigation
│   ├── patient_screen.dart        # Patient management
│   ├── appointment_screen.dart    # Appointment management
│   ├── billing_screen.dart        # Billing and payments
│   ├── report_screen.dart         # Reports and Excel export
│   └── settings_screen.dart       # Settings and backup/restore
├── models/
│   ├── patient_model.dart         # Patient data model
│   ├── appointment_model.dart     # Appointment data model
│   └── billing_model.dart         # Billing data model
├── database/
│   └── db_helper.dart             # SQLite database helper
├── utils/
│   ├── excel_export.dart          # Excel export functionality
│   └── backup_helper.dart         # Database backup/restore
└── widgets/
    ├── custom_button.dart         # Reusable button widget
    ├── custom_textfield.dart      # Reusable text field widget
    └── summary_card.dart          # Dashboard summary card widget
```

## Database

### Location
- Database file: `Documents\DentistClinicData\clinic_data.db`
- Backups: `Documents\DentistClinicData\Backups\`
- Excel exports: `Documents\DentistClinicData\clinic_data.xlsx`

### Tables

#### patients
- id, name, phone, age, gender, address, medical_history, allergies

#### appointments
- id, patient_id, date, time, reason, status

#### billing
- id, patient_id, treatment, cost, paid, date

#### settings
- id, password

## Default Data

The application comes with dummy data for testing:
- 5 sample patients
- 5 sample appointments
- 5 sample billing records

## Usage Instructions

### First Time Login
1. Launch the application
2. Enter password: `1234`
3. Click Login

### Adding a Patient
1. Navigate to Patients screen
2. Click "Add Patient" button
3. Fill in patient information
4. Click "Add"

### Creating an Appointment
1. Navigate to Appointments screen
2. Click "Add Appointment" button
3. Select patient, date, time, and reason
4. Click "Add"

### Adding Billing Record
1. Navigate to Billing screen
2. Click "Add Billing" button
3. Select patient, enter treatment details and amounts
4. Click "Add"

### Exporting to Excel
1. Navigate to Reports screen
2. Select date range (optional)
3. Click "Export to Excel" button
4. Find the file in `Documents\DentistClinicData\clinic_data.xlsx`

### Creating a Backup
1. Navigate to Settings screen
2. Click "Create Backup" button
3. Backup will be saved with timestamp in the Backups folder

### Restoring from Backup
1. Navigate to Settings screen
2. Find the backup you want to restore in the list
3. Click "Restore" button
4. Confirm the action
5. Restart the application

## Dependencies

- `sqflite_common_ffi`: ^2.3.0 - SQLite database
- `path_provider`: ^2.1.2 - File system paths
- `provider`: ^6.1.0 - State management
- `fl_chart`: ^0.65.0 - Charts and graphs
- `excel`: ^2.1.0 - Excel file generation
- `file_picker`: ^6.1.1 - File picking
- `shared_preferences`: ^2.2.2 - Local storage
- `flutter_slidable`: ^3.1.0 - Slidable list items
- `intl`: ^0.19.0 - Internationalization

## Build Information

- **Version**: 1.0.0
- **Platform**: Windows Desktop
- **Framework**: Flutter
- **Database**: SQLite
- **Offline**: Yes (fully offline functionality)

## Notes

- All data is stored locally on the Windows machine
- No internet connection required
- Data is automatically saved to the database
- Regular backups are recommended
- Default password should be changed after first login

## Troubleshooting

### App won't start
- Ensure Flutter is properly installed
- Run `flutter doctor` to check for issues
- Make sure you're using Flutter stable channel

### Database errors
- Check that the app has write permissions to Documents folder
- Try deleting the database and letting it recreate with fresh data

### Build errors
- Run `flutter clean` followed by `flutter pub get`
- Make sure all dependencies are compatible

## Future Enhancements

Potential features for future versions:
- Patient photo upload
- Treatment history timeline
- SMS/Email appointment reminders
- Multi-user support with roles
- Advanced reporting with charts
- Print functionality for invoices

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or questions, please create an issue in the project repository.
