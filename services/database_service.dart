// lib/services/database_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/medication_model.dart';
import '../models/health_log_model.dart';
import '../models/appointment_model.dart';

class DatabaseService {
  static const String _databaseName = 'mymedbuddy.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _userTable = 'users';
  static const String _medicationTable = 'medications';
  static const String _medicationLogTable = 'medication_logs';
  static const String _healthLogTable = 'health_logs';
  static const String _appointmentTable = 'appointments';
  static const String _settingsTable = 'settings';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onConfigure: _configureDatabase,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database: ${e.toString()}');
    }
  }

  Future<void> _configureDatabase(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDatabase(Database db, int version) async {
    await _createUserTable(db);
    await _createMedicationTable(db);
    await _createMedicationLogTable(db);
    await _createHealthLogTable(db);
    await _createAppointmentTable(db);
    await _createSettingsTable(db);
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Add migration logic for version 2
    }
  }

  // Create table methods
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_userTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        age INTEGER,
        condition TEXT,
        medication_reminders INTEGER DEFAULT 1,
        allergies TEXT,
        emergency_contact TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createMedicationTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_medicationTable(
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        times TEXT NOT NULL,
        instructions TEXT,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER DEFAULT 1,
        color TEXT DEFAULT 'primary',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_userTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createMedicationLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_medicationLogTable(
        id TEXT PRIMARY KEY,
        medication_id TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        taken_time TEXT,
        is_taken INTEGER DEFAULT 0,
        is_skipped INTEGER DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (medication_id) REFERENCES $_medicationTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createHealthLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_healthLogTable(
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        mood TEXT,
        symptoms TEXT,
        metrics TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_userTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAppointmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_appointmentTable(
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        title TEXT NOT NULL,
        doctor TEXT NOT NULL,
        specialty TEXT,
        location TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        duration INTEGER DEFAULT 30,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        notes TEXT,
        symptoms TEXT,
        medications TEXT,
        is_reminder_set INTEGER DEFAULT 1,
        reminder_minutes INTEGER DEFAULT 30,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_userTable (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_settingsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES $_userTable (id) ON DELETE CASCADE,
        UNIQUE(user_id, key)
      )
    ''');
  }

  // User operations
  Future<int> insertUser(UserModel user) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      return await db.insert(_userTable, {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'age': user.age,
        'condition': user.condition,
        'medication_reminders': user.medicationReminders ? 1 : 0,
        'allergies': jsonEncode(user.allergies),
        'emergency_contact': user.emergencyContact,
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      throw DatabaseException('Failed to insert user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _userTable,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return UserModel(
          name: results[0]['name'],
          email: results[0]['email'],
          phone: results[0]['phone'] ?? '',
          age: results[0]['age'] ?? 0,
          condition: results[0]['condition'] ?? '',
          medicationReminders: results[0]['medication_reminders'] == 1,
          allergies: List<String>.from(
            jsonDecode(results[0]['allergies'] ?? '[]'),
          ),
          emergencyContact: results[0]['emergency_contact'] ?? '',
        );
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(int userId, UserModel user) async {
    try {
      final db = await database;
      await db.update(
        _userTable,
        {
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'age': user.age,
          'condition': user.condition,
          'medication_reminders': user.medicationReminders ? 1 : 0,
          'allergies': jsonEncode(user.allergies),
          'emergency_contact': user.emergencyContact,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final db = await database;
      await db.delete(_userTable, where: 'id = ?', whereArgs: [userId]);
    } catch (e) {
      throw DatabaseException('Failed to delete user: ${e.toString()}');
    }
  }

  // Medication operations
  Future<void> insertMedication(MedicationModel medication, int userId) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      await db.insert(_medicationTable, {
        'id': medication.id,
        'user_id': userId,
        'name': medication.name,
        'dosage': medication.dosage,
        'frequency': medication.frequency,
        'times': jsonEncode(medication.times),
        'instructions': medication.instructions,
        'start_date': medication.startDate.toIso8601String(),
        'end_date': medication.endDate?.toIso8601String(),
        'is_active': medication.isActive ? 1 : 0,
        'color': medication.color,
        'created_at': now,
        'updated_at': now,
      });

      // Insert medication logs
      for (final log in medication.logs) {
        await insertMedicationLog(log);
      }
    } catch (e) {
      throw DatabaseException('Failed to insert medication: ${e.toString()}');
    }
  }

  Future<List<MedicationModel>> getMedications(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _medicationTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      List<MedicationModel> medications = [];
      for (final result in results) {
        final logs = await getMedicationLogs(result['id']);
        medications.add(
          MedicationModel(
            id: result['id'],
            name: result['name'],
            dosage: result['dosage'],
            frequency: result['frequency'],
            times: List<String>.from(jsonDecode(result['times'])),
            instructions: result['instructions'] ?? '',
            startDate: DateTime.parse(result['start_date']),
            endDate: result['end_date'] != null
                ? DateTime.parse(result['end_date'])
                : null,
            isActive: result['is_active'] == 1,
            color: result['color'] ?? 'primary',
            logs: logs,
          ),
        );
      }
      return medications;
    } catch (e) {
      throw DatabaseException('Failed to get medications: ${e.toString()}');
    }
  }

  Future<void> updateMedication(MedicationModel medication, int userId) async {
    try {
      final db = await database;
      await db.update(
        _medicationTable,
        {
          'name': medication.name,
          'dosage': medication.dosage,
          'frequency': medication.frequency,
          'times': jsonEncode(medication.times),
          'instructions': medication.instructions,
          'start_date': medication.startDate.toIso8601String(),
          'end_date': medication.endDate?.toIso8601String(),
          'is_active': medication.isActive ? 1 : 0,
          'color': medication.color,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [medication.id, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update medication: ${e.toString()}');
    }
  }

  Future<void> deleteMedication(String medicationId, int userId) async {
    try {
      final db = await database;
      await db.delete(
        _medicationTable,
        where: 'id = ? AND user_id = ?',
        whereArgs: [medicationId, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete medication: ${e.toString()}');
    }
  }

  // Medication log operations
  Future<void> insertMedicationLog(MedicationLog log) async {
    try {
      final db = await database;
      await db.insert(_medicationLogTable, {
        'id': log.id,
        'medication_id': log.medicationId,
        'scheduled_time': log.scheduledTime.toIso8601String(),
        'taken_time': log.takenTime?.toIso8601String(),
        'is_taken': log.isTaken ? 1 : 0,
        'is_skipped': log.isSkipped ? 1 : 0,
        'notes': log.notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw DatabaseException(
        'Failed to insert medication log: ${e.toString()}',
      );
    }
  }

  Future<List<MedicationLog>> getMedicationLogs(String medicationId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _medicationLogTable,
        where: 'medication_id = ?',
        whereArgs: [medicationId],
        orderBy: 'scheduled_time DESC',
      );

      return results
          .map(
            (result) => MedicationLog(
              id: result['id'],
              medicationId: result['medication_id'],
              scheduledTime: DateTime.parse(result['scheduled_time']),
              takenTime: result['taken_time'] != null
                  ? DateTime.parse(result['taken_time'])
                  : null,
              isTaken: result['is_taken'] == 1,
              isSkipped: result['is_skipped'] == 1,
              notes: result['notes'],
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get medication logs: ${e.toString()}');
    }
  }

  Future<void> updateMedicationLog(MedicationLog log) async {
    try {
      final db = await database;
      await db.update(
        _medicationLogTable,
        {
          'taken_time': log.takenTime?.toIso8601String(),
          'is_taken': log.isTaken ? 1 : 0,
          'is_skipped': log.isSkipped ? 1 : 0,
          'notes': log.notes,
        },
        where: 'id = ?',
        whereArgs: [log.id],
      );
    } catch (e) {
      throw DatabaseException(
        'Failed to update medication log: ${e.toString()}',
      );
    }
  }

  // Health log operations
  Future<void> insertHealthLog(HealthLogModel healthLog, int userId) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      await db.insert(_healthLogTable, {
        'id': healthLog.id,
        'user_id': userId,
        'title': healthLog.title,
        'description': healthLog.description,
        'type': healthLog.type.toString().split('.').last,
        'date': healthLog.date.toIso8601String(),
        'mood': healthLog.mood,
        'symptoms': jsonEncode(healthLog.symptoms),
        'metrics': jsonEncode(healthLog.metrics),
        'notes': healthLog.notes,
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      throw DatabaseException('Failed to insert health log: ${e.toString()}');
    }
  }

  Future<List<HealthLogModel>> getHealthLogs(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _healthLogTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );

      return results
          .map(
            (result) => HealthLogModel(
              id: result['id'],
              title: result['title'],
              description: result['description'],
              type: HealthLogType.values.firstWhere(
                (e) => e.toString().split('.').last == result['type'],
                orElse: () => HealthLogType.general,
              ),
              date: DateTime.parse(result['date']),
              mood: result['mood'],
              symptoms: List<String>.from(
                jsonDecode(result['symptoms'] ?? '[]'),
              ),
              metrics: Map<String, dynamic>.from(
                jsonDecode(result['metrics'] ?? '{}'),
              ),
              notes: result['notes'],
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get health logs: ${e.toString()}');
    }
  }

  Future<void> updateHealthLog(HealthLogModel healthLog, int userId) async {
    try {
      final db = await database;
      await db.update(
        _healthLogTable,
        {
          'title': healthLog.title,
          'description': healthLog.description,
          'type': healthLog.type.toString().split('.').last,
          'date': healthLog.date.toIso8601String(),
          'mood': healthLog.mood,
          'symptoms': jsonEncode(healthLog.symptoms),
          'metrics': jsonEncode(healthLog.metrics),
          'notes': healthLog.notes,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [healthLog.id, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update health log: ${e.toString()}');
    }
  }

  Future<void> deleteHealthLog(String healthLogId, int userId) async {
    try {
      final db = await database;
      await db.delete(
        _healthLogTable,
        where: 'id = ? AND user_id = ?',
        whereArgs: [healthLogId, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete health log: ${e.toString()}');
    }
  }

  // Appointment operations
  Future<void> insertAppointment(
    AppointmentModel appointment,
    int userId,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      await db.insert(_appointmentTable, {
        'id': appointment.id,
        'user_id': userId,
        'title': appointment.title,
        'doctor': appointment.doctorName,
        'specialty': appointment.specialty,
        'location': appointment.location,
        'date': appointment.dateTime.toIso8601String(),
        'time': _formatTimeOfDay(TimeOfDay.fromDateTime(appointment.dateTime)),
        'duration': appointment.duration.inMinutes,
        'type': appointment.type.toString().split('.').last,
        'status': appointment.status.toString().split('.').last,
        'description': appointment.description,
        'notes': appointment.notes,
        'symptoms': jsonEncode(appointment.symptoms),
        'medications': jsonEncode(appointment.medications),
        'is_reminder_set': appointment.isReminderSet ? 1 : 0,
        'reminder_minutes': appointment.reminderMinutes,
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      throw DatabaseException('Failed to insert appointment: ${e.toString()}');
    }
  }

  Future<List<AppointmentModel>> getAppointments(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _appointmentTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );

      return results.map((result) {
        return AppointmentModel(
          id: result['id'],
          title: result['title'],
          doctorName: result['doctor'],
          specialty: result['specialty'] ?? '',
          location: result['location'] ?? '',
          dateTime: DateTime.parse(result['date']),
          duration: Duration(minutes: result['duration']),
          type: AppointmentType.values.firstWhere(
            (e) => e.toString().split('.').last == result['type'],
            orElse: () => AppointmentType.checkup,
          ),
          status: AppointmentStatus.values.firstWhere(
            (e) => e.toString().split('.').last == result['status'],
            orElse: () => AppointmentStatus.scheduled,
          ),
          description: result['description'] ?? '',
          notes: result['notes'] ?? '',
          symptoms: List<String>.from(jsonDecode(result['symptoms'] ?? '[]')),
          medications: List<String>.from(
            jsonDecode(result['medications'] ?? '[]'),
          ),
          isReminderSet: result['is_reminder_set'] == 1,
          reminderMinutes: result['reminder_minutes'],
          createdAt: DateTime.parse(result['created_at']),
          updatedAt: DateTime.parse(result['updated_at']),
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get appointments: ${e.toString()}');
    }
  }

  Future<void> updateAppointment(
    AppointmentModel appointment,
    int userId,
  ) async {
    try {
      final db = await database;
      await db.update(
        _appointmentTable,
        {
          'title': appointment.title,
          'doctor': appointment.doctorName,
          'specialty': appointment.specialty,
          'location': appointment.location,
          'date': appointment.dateTime.toIso8601String(),
          'time': _formatTimeOfDay(
            TimeOfDay.fromDateTime(appointment.dateTime),
          ),
          'duration': appointment.duration.inMinutes,
          'type': appointment.type.toString().split('.').last,
          'status': appointment.status.toString().split('.').last,
          'description': appointment.description,
          'notes': appointment.notes,
          'symptoms': jsonEncode(appointment.symptoms),
          'medications': jsonEncode(appointment.medications),
          'is_reminder_set': appointment.isReminderSet ? 1 : 0,
          'reminder_minutes': appointment.reminderMinutes,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [appointment.id, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update appointment: ${e.toString()}');
    }
  }

  Future<void> deleteAppointment(String appointmentId, int userId) async {
    try {
      final db = await database;
      await db.delete(
        _appointmentTable,
        where: 'id = ? AND user_id = ?',
        whereArgs: [appointmentId, userId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete appointment: ${e.toString()}');
    }
  }

  // Settings operations
  Future<void> setSetting(int userId, String key, String value) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      await db.insert(_settingsTable, {
        'user_id': userId,
        'key': key,
        'value': value,
        'created_at': now,
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw DatabaseException('Failed to set setting: ${e.toString()}');
    }
  }

  Future<String?> getSetting(int userId, String key) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _settingsTable,
        columns: ['value'],
        where: 'user_id = ? AND key = ?',
        whereArgs: [userId, key],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return results.first['value'];
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get setting: ${e.toString()}');
    }
  }

  Future<Map<String, String>> getAllSettings(int userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        _settingsTable,
        columns: ['key', 'value'],
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      return Map.fromEntries(
        results.map((result) => MapEntry(result['key'], result['value'])),
      );
    } catch (e) {
      throw DatabaseException('Failed to get all settings: ${e.toString()}');
    }
  }

  Future<void> deleteSetting(int userId, String key) async {
    try {
      final db = await database;
      await db.delete(
        _settingsTable,
        where: 'user_id = ? AND key = ?',
        whereArgs: [userId, key],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete setting: ${e.toString()}');
    }
  }

  // Utility methods
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete(_settingsTable);
        await txn.delete(_appointmentTable);
        await txn.delete(_healthLogTable);
        await txn.delete(_medicationLogTable);
        await txn.delete(_medicationTable);
        await txn.delete(_userTable);
      });
    } catch (e) {
      throw DatabaseException('Failed to clear all data: ${e.toString()}');
    }
  }

  Future<void> clearUserData(int userId) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete(
          _settingsTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(
          _appointmentTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(
          _healthLogTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        // Get medications for this user to delete their logs
        final medications = await txn.query(
          _medicationTable,
          columns: ['id'],
          where: 'user_id = ?',
          whereArgs: [userId],
        );

        for (final medication in medications) {
          await txn.delete(
            _medicationLogTable,
            where: 'medication_id = ?',
            whereArgs: [medication['id']],
          );
        }

        await txn.delete(
          _medicationTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(_userTable, where: 'id = ?', whereArgs: [userId]);
      });
    } catch (e) {
      throw DatabaseException('Failed to clear user data: ${e.toString()}');
    }
  }

  Future<int> getDatabaseSize() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()',
      );
      return result.first['size'] as int;
    } catch (e) {
      throw DatabaseException('Failed to get database size: ${e.toString()}');
    }
  }

  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      throw DatabaseException('Failed to vacuum database: ${e.toString()}');
    }
  }

  Future<void> backup(String backupPath) async {
    try {
      final db = await database;
      final dbPath = db.path;
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
      }
    } catch (e) {
      throw DatabaseException('Failed to backup database: ${e.toString()}');
    }
  }

  Future<void> restore(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (await backupFile.exists()) {
        await _database?.close();
        _database = null;

        final db = await database;
        await backupFile.copy(db.path);

        // Reinitialize database
        await _database?.close();
        _database = null;
        await database;
      }
    } catch (e) {
      throw DatabaseException('Failed to restore database: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getHealthStats(int userId) async {
    try {
      final db = await database;

      final medicationCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_medicationTable WHERE user_id = ? AND is_active = 1',
        [userId],
      );

      final healthLogCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_healthLogTable WHERE user_id = ?',
        [userId],
      );

      final appointmentCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_appointmentTable WHERE user_id = ? AND date >= ?',
        [userId, DateTime.now().toIso8601String()],
      );

      final adherenceRate = await db.rawQuery(
        '''
        SELECT 
          (COUNT(CASE WHEN is_taken = 1 THEN 1 END) * 100.0 / COUNT(*)) as rate
        FROM $_medicationLogTable ml
        JOIN $_medicationTable m ON ml.medication_id = m.id
        WHERE m.user_id = ? AND ml.scheduled_time >= ?
      ''',
        [
          userId,
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        ],
      );

      return {
        'activeMedications': medicationCount.first['count'],
        'healthLogs': healthLogCount.first['count'],
        'upcomingAppointments': appointmentCount.first['count'],
        'adherenceRate': adherenceRate.first['rate'] ?? 0.0,
      };
    } catch (e) {
      throw DatabaseException('Failed to get health stats: ${e.toString()}');
    }
  }

  // Helper method to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

// Custom exception class
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
