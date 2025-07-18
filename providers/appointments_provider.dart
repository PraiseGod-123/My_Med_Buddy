// lib/providers/appointments_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/appointment_model.dart';

class AppointmentsProvider extends ChangeNotifier {
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _error;
  AppointmentType? _filterType;
  AppointmentStatus? _filterStatus;
  DateTime? _filterDate;
  String _searchQuery = '';

  // Getters
  List<AppointmentModel> get appointments => _filteredAppointments;
  List<AppointmentModel> get allAppointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AppointmentType? get filterType => _filterType;
  AppointmentStatus? get filterStatus => _filterStatus;
  DateTime? get filterDate => _filterDate;
  String get searchQuery => _searchQuery;

  // Filtered appointments based on current filters
  List<AppointmentModel> get _filteredAppointments {
    List<AppointmentModel> filtered = List.from(_appointments);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final query = _searchQuery.toLowerCase();
        return appointment.title.toLowerCase().contains(query) ||
            appointment.doctorName.toLowerCase().contains(query) ||
            appointment.specialty.toLowerCase().contains(query) ||
            appointment.location.toLowerCase().contains(query);
      }).toList();
    }

    // Apply type filter
    if (_filterType != null) {
      filtered = filtered
          .where((appointment) => appointment.type == _filterType)
          .toList();
    }

    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered
          .where((appointment) => appointment.status == _filterStatus)
          .toList();
    }

    // Apply date filter
    if (_filterDate != null) {
      filtered = filtered.where((appointment) {
        final appointmentDate = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );
        final filterDate = DateTime(
          _filterDate!.year,
          _filterDate!.month,
          _filterDate!.day,
        );
        return appointmentDate.isAtSameMomentAs(filterDate);
      }).toList();
    }

    // Sort by date (upcoming first)
    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return filtered;
  }

  // Convenience getters for common filters
  List<AppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (appointment) =>
              appointment.dateTime.isAfter(now) && appointment.status.isActive,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> get todaysAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _appointments
        .where(
          (appointment) =>
              appointment.dateTime.isAfter(today) &&
              appointment.dateTime.isBefore(tomorrow),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> get thisWeekAppointments {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _appointments
        .where(
          (appointment) =>
              appointment.dateTime.isAfter(weekStart) &&
              appointment.dateTime.isBefore(weekEnd),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) => appointment.dateTime.isBefore(now))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Most recent first
  }

  AppointmentModel? get nextAppointment {
    final upcoming = upcomingAppointments;
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  int get totalAppointments => _appointments.length;
  int get upcomingCount => upcomingAppointments.length;
  int get todaysCount => todaysAppointments.length;
  int get thisWeekCount => thisWeekAppointments.length;
  int get completedCount => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .length;

  // Statistics
  Map<AppointmentType, int> get appointmentsByType {
    final Map<AppointmentType, int> stats = {};
    for (final appointment in _appointments) {
      stats[appointment.type] = (stats[appointment.type] ?? 0) + 1;
    }
    return stats;
  }

  Map<AppointmentStatus, int> get appointmentsByStatus {
    final Map<AppointmentStatus, int> stats = {};
    for (final appointment in _appointments) {
      stats[appointment.status] = (stats[appointment.status] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> get appointmentsByDoctor {
    final Map<String, int> stats = {};
    for (final appointment in _appointments) {
      stats[appointment.doctorName] = (stats[appointment.doctorName] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> get appointmentsBySpecialty {
    final Map<String, int> stats = {};
    for (final appointment in _appointments) {
      stats[appointment.specialty] = (stats[appointment.specialty] ?? 0) + 1;
    }
    return stats;
  }

  // Data operations
  Future<void> loadAppointments() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getStringList('appointments') ?? [];

      _appointments = appointmentsJson.map((jsonStr) {
        final json = jsonDecode(jsonStr);
        return AppointmentModel.fromJson(json);
      }).toList();

      // Sort by date
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      _error = null;
    } catch (e) {
      _error = 'Failed to load appointments: ${e.toString()}';
    }
    _setLoading(false);
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      // Check for conflicts
      if (AppointmentUtils.hasConflict(appointment, _appointments)) {
        _error = 'This appointment conflicts with an existing appointment';
        notifyListeners();
        return;
      }

      _appointments.add(appointment);
      await _saveAppointments();
      _clearFilters(); // Clear filters to show new appointment
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == appointment.id);
      if (index != -1) {
        // Check for conflicts (excluding the current appointment)
        final otherAppointments = _appointments
            .where((a) => a.id != appointment.id)
            .toList();
        if (AppointmentUtils.hasConflict(appointment, otherAppointments)) {
          _error = 'This appointment conflicts with an existing appointment';
          notifyListeners();
          return;
        }

        _appointments[index] = appointment.copyWith(updatedAt: DateTime.now());
        await _saveAppointments();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    try {
      _appointments.removeWhere(
        (appointment) => appointment.id == appointmentId,
      );
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        if (appointment.canCancel) {
          _appointments[index] = appointment.copyWith(
            status: AppointmentStatus.cancelled,
            notes: '${appointment.notes}\nCancelled: $reason',
            updatedAt: DateTime.now(),
          );
          await _saveAppointments();
          notifyListeners();
        } else {
          _error = 'Cannot cancel this appointment';
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to cancel appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> completeAppointment(String appointmentId, String notes) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        if (appointment.canComplete) {
          _appointments[index] = appointment.copyWith(
            status: AppointmentStatus.completed,
            notes: notes.isEmpty ? appointment.notes : notes,
            updatedAt: DateTime.now(),
          );
          await _saveAppointments();
          notifyListeners();
        } else {
          _error = 'Cannot complete this appointment';
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to complete appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) async {
    try {
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        final appointment = _appointments[index];
        if (appointment.canReschedule) {
          final rescheduledAppointment = appointment.copyWith(
            dateTime: newDateTime,
            status: AppointmentStatus.rescheduled,
            notes:
                '${appointment.notes}\nRescheduled from: ${appointment.formattedDateTime}',
            updatedAt: DateTime.now(),
          );

          // Check for conflicts with new time
          final otherAppointments = _appointments
              .where((a) => a.id != appointmentId)
              .toList();
          if (AppointmentUtils.hasConflict(
            rescheduledAppointment,
            otherAppointments,
          )) {
            _error = 'The new time conflicts with an existing appointment';
            notifyListeners();
            return;
          }

          _appointments[index] = rescheduledAppointment;
          await _saveAppointments();
          notifyListeners();
        } else {
          _error = 'Cannot reschedule this appointment';
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to reschedule appointment: ${e.toString()}';
      notifyListeners();
    }
  }

  // Filter methods
  void setTypeFilter(AppointmentType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setStatusFilter(AppointmentStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _clearFilters();
    notifyListeners();
  }

  void _clearFilters() {
    _filterType = null;
    _filterStatus = null;
    _filterDate = null;
    _searchQuery = '';
  }

  // Utility methods
  List<AppointmentModel> getAppointmentsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _appointments.where((appointment) {
      return appointment.dateTime.isAfter(start) &&
          appointment.dateTime.isBefore(end);
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> getAppointmentsByDoctor(String doctorName) {
    return _appointments
        .where(
          (appointment) =>
              appointment.doctorName.toLowerCase() == doctorName.toLowerCase(),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<AppointmentModel> getAppointmentsBySpecialty(String specialty) {
    return _appointments
        .where(
          (appointment) =>
              appointment.specialty.toLowerCase() == specialty.toLowerCase(),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  bool hasAppointmentToday() {
    return todaysAppointments.isNotEmpty;
  }

  bool hasConflictingAppointment(
    DateTime dateTime,
    Duration duration, {
    String? excludeId,
  }) {
    final newAppointment = AppointmentModel(
      id: excludeId ?? 'temp',
      title: 'temp',
      doctorName: 'temp',
      specialty: 'temp',
      location: 'temp',
      dateTime: dateTime,
      duration: duration,
    );

    final appointmentsToCheck = excludeId != null
        ? _appointments.where((a) => a.id != excludeId).toList()
        : _appointments;

    return AppointmentUtils.hasConflict(newAppointment, appointmentsToCheck);
  }

  Duration getTimeBetweenAppointments(String firstId, String secondId) {
    final first = _appointments.firstWhere((a) => a.id == firstId);
    final second = _appointments.firstWhere((a) => a.id == secondId);
    return AppointmentUtils.getTimeBetweenAppointments(first, second);
  }

  // Private methods
  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = _appointments
        .map((appointment) => jsonEncode(appointment.toJson()))
        .toList();
    await prefs.setStringList('appointments', appointmentsJson);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sample data for testing
  Future<void> addSampleAppointments() async {
    final now = DateTime.now();
    final sampleAppointments = [
      AppointmentModel(
        id: '1',
        title: 'Annual Check-up',
        doctorName: 'Dr. Smith',
        specialty: 'General Medicine',
        location: 'City Medical Center',
        dateTime: now.add(const Duration(days: 1, hours: 10)),
        duration: const Duration(minutes: 30),
        type: AppointmentType.checkup,
        status: AppointmentStatus.scheduled,
        description: 'Annual physical examination and health screening',
        contactNumber: '+1234567890',
        address: '123 Health Street, Medical District',
        isReminderSet: true,
        reminderMinutes: 60,
      ),
      AppointmentModel(
        id: '2',
        title: 'Cardiology Consultation',
        doctorName: 'Dr. Johnson',
        specialty: 'Cardiology',
        location: 'Heart Care Clinic',
        dateTime: now.add(const Duration(days: 3, hours: 14)),
        duration: const Duration(minutes: 45),
        type: AppointmentType.consultation,
        status: AppointmentStatus.confirmed,
        description: 'Follow-up consultation for heart health monitoring',
        contactNumber: '+1234567891',
        address: '456 Cardiac Avenue, Medical District',
        isReminderSet: true,
        reminderMinutes: 120,
      ),
      AppointmentModel(
        id: '3',
        title: 'Dental Cleaning',
        doctorName: 'Dr. Brown',
        specialty: 'Dentistry',
        location: 'Smile Dental Clinic',
        dateTime: now.add(const Duration(days: 7, hours: 9)),
        duration: const Duration(minutes: 60),
        type: AppointmentType.dentistry,
        status: AppointmentStatus.scheduled,
        description: 'Regular dental cleaning and oral health check',
        contactNumber: '+1234567892',
        address: '789 Dental Lane, Health Plaza',
        isReminderSet: true,
        reminderMinutes: 30,
      ),
      AppointmentModel(
        id: '4',
        title: 'Physical Therapy Session',
        doctorName: 'Dr. Wilson',
        specialty: 'Physical Therapy',
        location: 'Rehabilitation Center',
        dateTime: now.subtract(const Duration(days: 2, hours: 11)),
        duration: const Duration(minutes: 60),
        type: AppointmentType.therapy,
        status: AppointmentStatus.completed,
        description: 'Lower back pain rehabilitation session',
        contactNumber: '+1234567893',
        address: '321 Recovery Road, Wellness Center',
        notes: 'Great progress shown. Continue exercises at home.',
        isReminderSet: false,
      ),
    ];

    for (final appointment in sampleAppointments) {
      await addAppointment(appointment);
    }
  }

  // Bulk operations
  Future<void> bulkUpdateStatus(
    List<String> appointmentIds,
    AppointmentStatus status,
  ) async {
    try {
      bool hasChanges = false;
      for (final id in appointmentIds) {
        final index = _appointments.indexWhere((a) => a.id == id);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _saveAppointments();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update appointments: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> bulkDelete(List<String> appointmentIds) async {
    try {
      _appointments.removeWhere(
        (appointment) => appointmentIds.contains(appointment.id),
      );
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete appointments: ${e.toString()}';
      notifyListeners();
    }
  }

  // Export functionality
  Map<String, dynamic> exportAppointments() {
    return {
      'appointments': _appointments.map((a) => a.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'totalCount': _appointments.length,
    };
  }

  Future<void> importAppointments(Map<String, dynamic> data) async {
    try {
      final appointmentsData = data['appointments'] as List;
      final importedAppointments = appointmentsData
          .map((json) => AppointmentModel.fromJson(json))
          .toList();

      _appointments.addAll(importedAppointments);
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to import appointments: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadAppointments();
  }
}
