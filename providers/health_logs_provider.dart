import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_log_model.dart';

class HealthLogsProvider extends ChangeNotifier {
  List<HealthLogModel> _healthLogs = [];
  bool _isLoading = false;
  String? _error;
  HealthLogType? _filterType;

  List<HealthLogModel> get healthLogs => _filteredLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  HealthLogType? get filterType => _filterType;

  List<HealthLogModel> get _filteredLogs {
    if (_filterType == null) {
      return _healthLogs;
    }
    return _healthLogs.where((log) => log.type == _filterType).toList();
  }

  List<HealthLogModel> get recentLogs {
    final sortedLogs = List<HealthLogModel>.from(_healthLogs);
    sortedLogs.sort((a, b) => b.date.compareTo(a.date));
    return sortedLogs.take(5).toList();
  }

  Map<HealthLogType, int> get logCountsByType {
    final counts = <HealthLogType, int>{};
    for (final type in HealthLogType.values) {
      counts[type] = _healthLogs.where((log) => log.type == type).length;
    }
    return counts;
  }

  Future<void> loadHealthLogs() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getStringList('health_logs') ?? [];

      _healthLogs = logsJson.map((jsonStr) {
        final json = jsonDecode(jsonStr);
        return HealthLogModel.fromJson(json);
      }).toList();

      // Sort by date (newest first)
      _healthLogs.sort((a, b) => b.date.compareTo(a.date));

      _error = null;
    } catch (e) {
      _error = 'Failed to load health logs: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> addHealthLog(HealthLogModel log) async {
    try {
      _healthLogs.add(log);
      _healthLogs.sort((a, b) => b.date.compareTo(a.date));
      await _saveHealthLogs();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add health log: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateHealthLog(HealthLogModel log) async {
    try {
      final index = _healthLogs.indexWhere((l) => l.id == log.id);
      if (index != -1) {
        _healthLogs[index] = log;
        _healthLogs.sort((a, b) => b.date.compareTo(a.date));
        await _saveHealthLogs();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update health log: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteHealthLog(String logId) async {
    try {
      _healthLogs.removeWhere((log) => log.id == logId);
      await _saveHealthLogs();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete health log: ${e.toString()}';
      notifyListeners();
    }
  }

  void setFilter(HealthLogType? type) {
    _filterType = type;
    notifyListeners();
  }

  Future<void> _saveHealthLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = _healthLogs
        .map((log) => jsonEncode(log.toJson()))
        .toList();
    await prefs.setStringList('health_logs', logsJson);
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
  Future<void> addSampleHealthLogs() async {
    final now = DateTime.now();
    final sampleLogs = [
      HealthLogModel(
        id: '1',
        date: now.subtract(const Duration(hours: 2)),
        title: 'Morning Vitals',
        description: 'Checked blood pressure and heart rate',
        type: HealthLogType.vitals,
        metrics: {
          'blood_pressure_systolic': 120,
          'blood_pressure_diastolic': 80,
          'heart_rate': 72,
        },
      ),
      HealthLogModel(
        id: '2',
        date: now.subtract(const Duration(days: 1)),
        title: 'Evening Mood Check',
        description: 'Feeling good after workout',
        type: HealthLogType.mood,
        mood: 'Good',
        notes: 'Had a great day at work and completed my exercise routine',
      ),
      HealthLogModel(
        id: '3',
        date: now.subtract(const Duration(days: 2)),
        title: 'Mild Headache',
        description: 'Experiencing slight headache',
        type: HealthLogType.symptoms,
        symptoms: ['Headache', 'Fatigue'],
        notes: 'Possibly due to lack of sleep',
      ),
    ];

    for (final log in sampleLogs) {
      await addHealthLog(log);
    }
  }
}
