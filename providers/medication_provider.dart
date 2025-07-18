import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/medication_model.dart';

class MedicationProvider extends ChangeNotifier {
  List<MedicationModel> _medications = [];
  bool _isLoading = false;
  String? _error;

  List<MedicationModel> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MedicationModel> get activeMedications =>
      _medications.where((med) => med.isActive).toList();

  List<MedicationModel> get todaysMedications {
    final now = DateTime.now();
    return activeMedications.where((med) {
      if (med.endDate != null && med.endDate!.isBefore(now)) {
        return false;
      }
      return med.startDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  MedicationModel? get nextMedication {
    final now = DateTime.now();
    final todayMeds = todaysMedications;

    MedicationModel? nextMed;
    DateTime? nextTime;

    for (final med in todayMeds) {
      for (final timeStr in med.times) {
        final time = _parseTimeString(timeStr);
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (scheduledDateTime.isAfter(now)) {
          if (nextTime == null || scheduledDateTime.isBefore(nextTime)) {
            nextTime = scheduledDateTime;
            nextMed = med;
          }
        }
      }
    }

    return nextMed;
  }

  int get missedDosesToday {
    final now = DateTime.now();
    int missed = 0;

    for (final med in todaysMedications) {
      for (final timeStr in med.times) {
        final time = _parseTimeString(timeStr);
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (scheduledDateTime.isBefore(now)) {
          // Check if this dose was taken
          final logExists = med.logs.any(
            (log) =>
                log.scheduledTime.day == now.day &&
                log.scheduledTime.month == now.month &&
                log.scheduledTime.year == now.year &&
                log.scheduledTime.hour == time.hour &&
                log.scheduledTime.minute == time.minute &&
                (log.isTaken || log.isSkipped),
          );

          if (!logExists) {
            missed++;
          }
        }
      }
    }

    return missed;
  }

  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<void> loadMedications() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicationsJson = prefs.getStringList('medications') ?? [];

      _medications = medicationsJson.map((jsonStr) {
        final json = jsonDecode(jsonStr);
        return MedicationModel.fromJson(json);
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Failed to load medications: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> addMedication(MedicationModel medication) async {
    try {
      _medications.add(medication);
      await _saveMedications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add medication: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateMedication(MedicationModel medication) async {
    try {
      final index = _medications.indexWhere((med) => med.id == medication.id);
      if (index != -1) {
        _medications[index] = medication;
        await _saveMedications();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update medication: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String medicationId) async {
    try {
      _medications.removeWhere((med) => med.id == medicationId);
      await _saveMedications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete medication: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> logMedication({
    required String medicationId,
    required DateTime scheduledTime,
    DateTime? takenTime,
    bool isTaken = true,
    bool isSkipped = false,
    String? notes,
  }) async {
    try {
      final medIndex = _medications.indexWhere((med) => med.id == medicationId);
      if (medIndex == -1) return;

      final medication = _medications[medIndex];
      final logId = DateTime.now().millisecondsSinceEpoch.toString();

      final log = MedicationLog(
        id: logId,
        medicationId: medicationId,
        scheduledTime: scheduledTime,
        takenTime: takenTime ?? (isTaken ? DateTime.now() : null),
        isTaken: isTaken,
        isSkipped: isSkipped,
        notes: notes,
      );

      final updatedLogs = List<MedicationLog>.from(medication.logs);

      // Remove existing log for this scheduled time if it exists
      updatedLogs.removeWhere(
        (existingLog) =>
            existingLog.scheduledTime.day == scheduledTime.day &&
            existingLog.scheduledTime.month == scheduledTime.month &&
            existingLog.scheduledTime.year == scheduledTime.year &&
            existingLog.scheduledTime.hour == scheduledTime.hour &&
            existingLog.scheduledTime.minute == scheduledTime.minute,
      );

      updatedLogs.add(log);

      _medications[medIndex] = medication.copyWith(logs: updatedLogs);
      await _saveMedications();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to log medication: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsJson = _medications
        .map((med) => jsonEncode(med.toJson()))
        .toList();
    await prefs.setStringList('medications', medicationsJson);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Generate sample data for demo purposes
  Future<void> addSampleMedications() async {
    final sampleMeds = [
      MedicationModel(
        id: '1',
        name: 'Vitamin D',
        dosage: '1000mg',
        frequency: 'Once daily',
        times: ['08:00'],
        instructions: 'Take with breakfast',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        color: 'primary',
      ),
      MedicationModel(
        id: '2',
        name: 'Omega-3',
        dosage: '500mg',
        frequency: 'Twice daily',
        times: ['08:00', '20:00'],
        instructions: 'Take with meals',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        color: 'secondary',
      ),
    ];

    for (final med in sampleMeds) {
      await addMedication(med);
    }
  }
}
