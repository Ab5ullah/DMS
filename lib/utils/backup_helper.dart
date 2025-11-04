import 'dart:io';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class BackupHelper {
  static Future<String> backupDatabase() async {
    try {
      final documentsPath = Platform.environment['USERPROFILE'] ?? '';
      final dbPath = join(documentsPath, 'Documents', 'DentistClinicData', 'clinic_data.db');
      final backupDir = join(documentsPath, 'Documents', 'DentistClinicData', 'Backups');

      // Create backup directory if it doesn't exist
      final directory = Directory(backupDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create backup file with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupPath = join(backupDir, 'clinic_data_backup_$timestamp.db');

      // Copy database file
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        // Read and write to avoid file locking issues
        final bytes = await dbFile.readAsBytes();
        await File(backupPath).writeAsBytes(bytes);
        return backupPath;
      } else {
        throw Exception('Database file not found');
      }
    } catch (e) {
      throw Exception('Error creating backup: ${e.toString()}');
    }
  }

  static Future<void> restoreDatabase(String backupPath) async {
    try {
      final documentsPath = Platform.environment['USERPROFILE'] ?? '';
      final dbPath = join(documentsPath, 'Documents', 'DentistClinicData', 'clinic_data.db');

      // Check if backup file exists
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Read backup and write to database location
      final bytes = await backupFile.readAsBytes();
      await File(dbPath).writeAsBytes(bytes);
    } catch (e) {
      throw Exception('Error restoring backup: ${e.toString()}');
    }
  }

  static Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final documentsPath = Platform.environment['USERPROFILE'] ?? '';
      final backupDir = join(documentsPath, 'Documents', 'DentistClinicData', 'Backups');

      final directory = Directory(backupDir);
      if (!await directory.exists()) {
        return [];
      }

      final files = directory.listSync()
          .where((file) => file.path.endsWith('.db'))
          .toList();

      // Sort by date (newest first)
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      return files;
    } catch (e) {
      throw Exception('Error getting backup files: ${e.toString()}');
    }
  }
}
