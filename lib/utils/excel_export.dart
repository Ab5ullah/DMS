import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart';
import '../database/db_helper.dart';

class ExcelExport {
  static Future<String> exportAllData() async {
    try {
      // Create Excel document
      var excel = Excel.createExcel();

      // Export Patients
      await _exportPatients(excel);

      // Export Appointments
      await _exportAppointments(excel);

      // Export Billing
      await _exportBilling(excel);

      // Delete default sheet if it exists (do this after all sheets are created)
      try {
        if (excel.tables.containsKey('Sheet1')) {
          excel.delete('Sheet1');
        }
      } catch (e) {
        // Ignore if we can't delete the default sheet
      }

      // Save file
      final documentsPath = Platform.environment['USERPROFILE'] ?? '';
      final exportPath = join(documentsPath, 'Documents', 'DentistClinicData');

      // Create directory if it doesn't exist
      final directory = Directory(exportPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = join(exportPath, 'clinic_data.xlsx');

      // Save to bytes and write to file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
      }

      return filePath;
    } catch (e) {
      throw Exception('Error exporting data: ${e.toString()}');
    }
  }

  static Future<void> _exportPatients(Excel excel) async {
    var sheet = excel['Patients'];

    // Add headers with styling
    final headers = [
      'Patient ID',
      'Name',
      'Phone',
      'Age',
      'Gender',
      'Address',
      'Medical History',
      'Allergies'
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
    }

    // Add data
    final patients = await DBHelper.instance.getAllPatients();
    for (var i = 0; i < patients.length; i++) {
      final patient = patients[i];
      final rowIndex = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = patient['patient_id'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = patient['name'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = patient['phone'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = patient['age']?.toString() ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = patient['gender'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = patient['address'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = patient['medical_history'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = patient['allergies'] ?? '';
    }
  }

  static Future<void> _exportAppointments(Excel excel) async {
    var sheet = excel['Appointments'];

    // Add headers
    final headers = [
      'ID',
      'Patient Name',
      'Date',
      'Time',
      'Reason',
      'Status'
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
    }

    // Add data
    final appointments = await DBHelper.instance.getAllAppointments();
    for (var i = 0; i < appointments.length; i++) {
      final appointment = appointments[i];
      final rowIndex = i + 1;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = appointment['id']?.toString() ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = appointment['patient_name'] ?? 'Unknown';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = appointment['date'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = appointment['time'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = appointment['reason'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = appointment['status'] ?? '';
    }
  }

  static Future<void> _exportBilling(Excel excel) async {
    var sheet = excel['Billing'];

    // Add headers
    final headers = [
      'ID',
      'Patient Name',
      'Treatment',
      'Cost',
      'Paid',
      'Balance',
      'Date'
    ];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
    }

    // Add data
    final billings = await DBHelper.instance.getAllBilling();
    for (var i = 0; i < billings.length; i++) {
      final billing = billings[i];
      final rowIndex = i + 1;
      final cost = (billing['cost'] as num).toDouble();
      final paid = (billing['paid'] as num).toDouble();
      final balance = cost - paid;

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = billing['id']?.toString() ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = billing['patient_name'] ?? 'Unknown';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = billing['treatment'] ?? '';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = cost;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = paid;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = balance;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = billing['date'] ?? '';
    }
  }
}
