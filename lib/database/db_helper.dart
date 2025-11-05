import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._internal();

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Get Documents directory path
    final documentsPath = Platform.environment['USERPROFILE'] ?? '';
    final dbPath = join(documentsPath, 'Documents', 'DentistClinicData');

    // Create directory if it doesn't exist
    final directory = Directory(dbPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final path = join(dbPath, 'clinic_data.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create patients table
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT UNIQUE,
        name TEXT NOT NULL,
        phone TEXT,
        cnic TEXT,
        age INTEGER,
        gender TEXT,
        address TEXT,
        medical_history TEXT,
        allergies TEXT
      )
    ''');

    // Create appointments table
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        reason TEXT,
        status TEXT DEFAULT 'Pending',
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Create billing table
    await db.execute('''
      CREATE TABLE billing (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        treatment TEXT NOT NULL,
        cost REAL NOT NULL,
        paid REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY,
        password TEXT NOT NULL
      )
    ''');

    // Create treatment templates table
    await db.execute('''
      CREATE TABLE treatment_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL,
        description TEXT
      )
    ''');

    // Create tooth treatments table
    await db.execute('''
      CREATE TABLE tooth_treatments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        tooth_number INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        billing_id INTEGER,
        cost REAL,
        FOREIGN KEY (patient_id) REFERENCES patients (id),
        FOREIGN KEY (billing_id) REFERENCES billing (id)
      )
    ''');

    // Insert default password
    await db.insert('settings', {'id': 1, 'password': '1234'});

    // Insert default treatment templates
    await db.insert('treatment_templates', {'name': 'Regular Checkup', 'cost': 100.0, 'description': 'Routine dental examination'});
    await db.insert('treatment_templates', {'name': 'Tooth Cleaning', 'cost': 150.0, 'description': 'Professional dental cleaning'});
    await db.insert('treatment_templates', {'name': 'Cavity Filling', 'cost': 200.0, 'description': 'Single cavity filling'});
    await db.insert('treatment_templates', {'name': 'Root Canal', 'cost': 800.0, 'description': 'Root canal therapy'});
    await db.insert('treatment_templates', {'name': 'Tooth Extraction', 'cost': 250.0, 'description': 'Simple tooth extraction'});
    await db.insert('treatment_templates', {'name': 'Dental Crown', 'cost': 1200.0, 'description': 'Porcelain dental crown'});
    await db.insert('treatment_templates', {'name': 'Teeth Whitening', 'cost': 500.0, 'description': 'Professional teeth whitening'});
    await db.insert('treatment_templates', {'name': 'Dental Implant', 'cost': 2500.0, 'description': 'Single dental implant'});

    // Insert dummy data
    await _insertDummyData(db);
  }

  Future<void> _insertDummyData(Database db) async {
    // Insert dummy patients
    final patients = [
      {
        'patient_id': 'PAT-001',
        'name': 'John Smith',
        'phone': '555-0101',
        'age': 35,
        'gender': 'Male',
        'address': '123 Main St, City',
        'medical_history': 'Hypertension',
        'allergies': 'Penicillin'
      },
      {
        'patient_id': 'PAT-002',
        'name': 'Sarah Johnson',
        'phone': '555-0102',
        'age': 28,
        'gender': 'Female',
        'address': '456 Oak Ave, City',
        'medical_history': 'None',
        'allergies': 'None'
      },
      {
        'patient_id': 'PAT-003',
        'name': 'Michael Brown',
        'phone': '555-0103',
        'age': 42,
        'gender': 'Male',
        'address': '789 Pine Rd, City',
        'medical_history': 'Diabetes Type 2',
        'allergies': 'Latex'
      },
      {
        'patient_id': 'PAT-004',
        'name': 'Emily Davis',
        'phone': '555-0104',
        'age': 31,
        'gender': 'Female',
        'address': '321 Elm St, City',
        'medical_history': 'Asthma',
        'allergies': 'None'
      },
      {
        'patient_id': 'PAT-005',
        'name': 'David Wilson',
        'phone': '555-0105',
        'age': 55,
        'gender': 'Male',
        'address': '654 Maple Dr, City',
        'medical_history': 'Heart Disease',
        'allergies': 'Aspirin'
      },
    ];

    for (var patient in patients) {
      await db.insert('patients', patient);
    }

    // Insert dummy appointments
    final appointments = [
      {
        'patient_id': 1,
        'date': DateTime.now().toString().split(' ')[0],
        'time': '09:00',
        'reason': 'Regular checkup',
        'status': 'Pending'
      },
      {
        'patient_id': 2,
        'date': DateTime.now().toString().split(' ')[0],
        'time': '10:30',
        'reason': 'Tooth cleaning',
        'status': 'Completed'
      },
      {
        'patient_id': 3,
        'date': DateTime.now().add(Duration(days: 1)).toString().split(' ')[0],
        'time': '14:00',
        'reason': 'Root canal',
        'status': 'Pending'
      },
      {
        'patient_id': 4,
        'date': DateTime.now().toString().split(' ')[0],
        'time': '15:30',
        'reason': 'Cavity filling',
        'status': 'Completed'
      },
      {
        'patient_id': 5,
        'date': DateTime.now().add(Duration(days: 2)).toString().split(' ')[0],
        'time': '11:00',
        'reason': 'Dental implant consultation',
        'status': 'Pending'
      },
    ];

    for (var appointment in appointments) {
      await db.insert('appointments', appointment);
    }

    // Insert dummy billing records
    final billingRecords = [
      {
        'patient_id': 1,
        'treatment': 'Regular checkup',
        'cost': 100.0,
        'paid': 100.0,
        'date': DateTime.now().subtract(Duration(days: 30)).toString().split(' ')[0]
      },
      {
        'patient_id': 2,
        'treatment': 'Tooth cleaning',
        'cost': 150.0,
        'paid': 150.0,
        'date': DateTime.now().subtract(Duration(days: 15)).toString().split(' ')[0]
      },
      {
        'patient_id': 3,
        'treatment': 'Root canal',
        'cost': 800.0,
        'paid': 400.0,
        'date': DateTime.now().subtract(Duration(days: 7)).toString().split(' ')[0]
      },
      {
        'patient_id': 4,
        'treatment': 'Cavity filling',
        'cost': 200.0,
        'paid': 200.0,
        'date': DateTime.now().subtract(Duration(days: 5)).toString().split(' ')[0]
      },
      {
        'patient_id': 5,
        'treatment': 'Dental implant',
        'cost': 2500.0,
        'paid': 1000.0,
        'date': DateTime.now().subtract(Duration(days: 2)).toString().split(' ')[0]
      },
    ];

    for (var billing in billingRecords) {
      await db.insert('billing', billing);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add patient_id column to existing patients table
      await db.execute('ALTER TABLE patients ADD COLUMN patient_id TEXT');

      // Generate patient IDs for existing patients
      final patients = await db.query('patients');
      for (var i = 0; i < patients.length; i++) {
        final patient = patients[i];
        final patientId = 'PAT-${(patient['id'] as int).toString().padLeft(3, '0')}';
        await db.update(
          'patients',
          {'patient_id': patientId},
          where: 'id = ?',
          whereArgs: [patient['id']],
        );
      }
    }
    if (oldVersion < 3) {
      // Add cnic column to existing patients table
      await db.execute('ALTER TABLE patients ADD COLUMN cnic TEXT');
    }
    if (oldVersion < 4) {
      // Add tooth_treatments table
      await db.execute('''
        CREATE TABLE tooth_treatments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id INTEGER NOT NULL,
          tooth_number INTEGER NOT NULL,
          procedure TEXT NOT NULL,
          status TEXT NOT NULL,
          date TEXT NOT NULL,
          notes TEXT,
          billing_id INTEGER,
          cost REAL,
          FOREIGN KEY (patient_id) REFERENCES patients (id),
          FOREIGN KEY (billing_id) REFERENCES billing (id)
        )
      ''');
    }
  }

  // Generate next patient ID
  Future<String> _generatePatientId() async {
    final db = await database;
    final result = await db.rawQuery('SELECT MAX(id) as max_id FROM patients');
    final maxId = result.first['max_id'] as int?;
    final nextId = (maxId ?? 0) + 1;
    return 'PAT-${nextId.toString().padLeft(3, '0')}';
  }

  // Patient CRUD operations
  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    // Auto-generate patient ID if not provided
    if (patient['patient_id'] == null) {
      patient['patient_id'] = await _generatePatientId();
    }
    return await db.insert('patients', patient);
  }

  Future<List<Map<String, dynamic>>> getAllPatients() async {
    final db = await database;
    return await db.query('patients', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getPatient(int id) async {
    final db = await database;
    final results = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updatePatient(Map<String, dynamic> patient) async {
    final db = await database;
    return await db.update('patients', patient, where: 'id = ?', whereArgs: [patient['id']]);
  }

  Future<int> deletePatient(int id) async {
    final db = await database;

    // Delete related appointments first
    await db.delete('appointments', where: 'patient_id = ?', whereArgs: [id]);

    // Delete related billing records
    await db.delete('billing', where: 'patient_id = ?', whereArgs: [id]);

    // Finally delete the patient
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    final db = await database;
    return await db.query(
      'patients',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
  }

  // Appointment CRUD operations
  Future<int> insertAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment);
  }

  Future<List<Map<String, dynamic>>> getAllAppointments() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, p.name as patient_name
      FROM appointments a
      LEFT JOIN patients p ON a.patient_id = p.id
      ORDER BY a.date DESC, a.time DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getAppointmentsByDate(String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT a.*, p.name as patient_name
      FROM appointments a
      LEFT JOIN patients p ON a.patient_id = p.id
      WHERE a.date = ?
      ORDER BY a.time ASC
    ''', [date]);
  }

  Future<int> updateAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    return await db.update('appointments', appointment, where: 'id = ?', whereArgs: [appointment['id']]);
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPatientAppointments(int patientId) async {
    final db = await database;
    return await db.query('appointments', where: 'patient_id = ?', whereArgs: [patientId], orderBy: 'date DESC');
  }

  // Billing CRUD operations
  Future<int> insertBilling(Map<String, dynamic> billing) async {
    final db = await database;
    return await db.insert('billing', billing);
  }

  Future<List<Map<String, dynamic>>> getAllBilling() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT b.*, p.name as patient_name
      FROM billing b
      LEFT JOIN patients p ON b.patient_id = p.id
      ORDER BY b.date DESC
    ''');
  }

  Future<int> updateBilling(Map<String, dynamic> billing) async {
    final db = await database;
    return await db.update('billing', billing, where: 'id = ?', whereArgs: [billing['id']]);
  }

  Future<int> deleteBilling(int id) async {
    final db = await database;
    return await db.delete('billing', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getPatientBilling(int patientId) async {
    final db = await database;
    return await db.query('billing', where: 'patient_id = ?', whereArgs: [patientId], orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getBillingByDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT b.*, p.name as patient_name
      FROM billing b
      LEFT JOIN patients p ON b.patient_id = p.id
      WHERE b.date BETWEEN ? AND ?
      ORDER BY b.date DESC
    ''', [startDate, endDate]);
  }

  // Treatment Templates operations
  Future<List<Map<String, dynamic>>> getAllTreatmentTemplates() async {
    final db = await database;
    return await db.query('treatment_templates', orderBy: 'name ASC');
  }

  Future<int> insertTreatmentTemplate(Map<String, dynamic> template) async {
    final db = await database;
    return await db.insert('treatment_templates', template);
  }

  Future<int> updateTreatmentTemplate(Map<String, dynamic> template) async {
    final db = await database;
    return await db.update('treatment_templates', template, where: 'id = ?', whereArgs: [template['id']]);
  }

  Future<int> deleteTreatmentTemplate(int id) async {
    final db = await database;
    return await db.delete('treatment_templates', where: 'id = ?', whereArgs: [id]);
  }

  // Settings operations
  Future<String?> getPassword() async {
    final db = await database;
    final results = await db.query('settings', where: 'id = ?', whereArgs: [1]);
    return results.isNotEmpty ? results.first['password'] as String : null;
  }

  Future<int> updatePassword(String newPassword) async {
    final db = await database;
    return await db.update('settings', {'password': newPassword}, where: 'id = ?', whereArgs: [1]);
  }

  // Dashboard statistics
  Future<int> getTotalPatients() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM patients');
    final count = result.first['count'];
    return count != null ? count as int : 0;
  }

  Future<int> getTodayAppointments() async {
    final db = await database;
    final today = DateTime.now().toString().split(' ')[0];
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM appointments WHERE date = ?', [today]);
    final count = result.first['count'];
    return count != null ? count as int : 0;
  }

  Future<double> getMonthlyIncome() async {
    final db = await database;
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1).toString().split(' ')[0];
    final endDate = DateTime(now.year, now.month + 1, 0).toString().split(' ')[0];

    final result = await db.rawQuery(
      'SELECT SUM(paid) as total FROM billing WHERE date BETWEEN ? AND ?',
      [startDate, endDate],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  Future<double> getTotalIncome(String startDate, String endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(paid) as total FROM billing WHERE date BETWEEN ? AND ?',
      [startDate, endDate],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  Future<double> getTotalIncomeAll() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(paid) as total FROM billing',
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  Future<double> getTotalUnpaid() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(cost - paid) as total FROM billing WHERE cost > paid',
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as num).toDouble()
        : 0.0;
  }

  // Tooth Treatment CRUD operations
  Future<int> insertToothTreatment(Map<String, dynamic> treatment) async {
    final db = await database;
    return await db.insert('tooth_treatments', treatment);
  }

  Future<List<Map<String, dynamic>>> getPatientToothTreatments(int patientId) async {
    final db = await database;
    return await db.query(
      'tooth_treatments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getToothTreatments(int patientId, int toothNumber) async {
    final db = await database;
    return await db.query(
      'tooth_treatments',
      where: 'patient_id = ? AND tooth_number = ?',
      whereArgs: [patientId, toothNumber],
      orderBy: 'date DESC',
    );
  }

  Future<Map<String, dynamic>?> getLatestToothStatus(int patientId, int toothNumber) async {
    final db = await database;
    final results = await db.query(
      'tooth_treatments',
      where: 'patient_id = ? AND tooth_number = ?',
      whereArgs: [patientId, toothNumber],
      orderBy: 'date DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateToothTreatment(Map<String, dynamic> treatment) async {
    final db = await database;
    return await db.update(
      'tooth_treatments',
      treatment,
      where: 'id = ?',
      whereArgs: [treatment['id']],
    );
  }

  Future<int> deleteToothTreatment(int id) async {
    final db = await database;
    return await db.delete('tooth_treatments', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
