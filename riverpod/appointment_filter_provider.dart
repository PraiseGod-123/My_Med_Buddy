// lib/riverpod/appointment_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';

// State class for appointment filtering
class AppointmentFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AppointmentType> selectedTypes;
  final List<AppointmentStatus> selectedStatuses;
  final List<String> selectedDoctors;
  final List<String> selectedSpecialties;
  final List<String> selectedLocations;
  final String searchQuery;
  final AppointmentSortBy sortBy;
  final bool isAscending;
  final bool showUpcomingOnly;
  final bool showTodayOnly;
  final int? reminderThreshold; // Minutes before appointment

  const AppointmentFilter({
    this.startDate,
    this.endDate,
    this.selectedTypes = const [],
    this.selectedStatuses = const [],
    this.selectedDoctors = const [],
    this.selectedSpecialties = const [],
    this.selectedLocations = const [],
    this.searchQuery = '',
    this.sortBy = AppointmentSortBy.dateTime,
    this.isAscending = true,
    this.showUpcomingOnly = false,
    this.showTodayOnly = false,
    this.reminderThreshold,
  });

  AppointmentFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<AppointmentType>? selectedTypes,
    List<AppointmentStatus>? selectedStatuses,
    List<String>? selectedDoctors,
    List<String>? selectedSpecialties,
    List<String>? selectedLocations,
    String? searchQuery,
    AppointmentSortBy? sortBy,
    bool? isAscending,
    bool? showUpcomingOnly,
    bool? showTodayOnly,
    int? reminderThreshold,
  }) {
    return AppointmentFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      selectedDoctors: selectedDoctors ?? this.selectedDoctors,
      selectedSpecialties: selectedSpecialties ?? this.selectedSpecialties,
      selectedLocations: selectedLocations ?? this.selectedLocations,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
      showUpcomingOnly: showUpcomingOnly ?? this.showUpcomingOnly,
      showTodayOnly: showTodayOnly ?? this.showTodayOnly,
      reminderThreshold: reminderThreshold ?? this.reminderThreshold,
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        selectedTypes.isNotEmpty ||
        selectedStatuses.isNotEmpty ||
        selectedDoctors.isNotEmpty ||
        selectedSpecialties.isNotEmpty ||
        selectedLocations.isNotEmpty ||
        searchQuery.isNotEmpty ||
        sortBy != AppointmentSortBy.dateTime ||
        !isAscending ||
        showUpcomingOnly ||
        showTodayOnly ||
        reminderThreshold != null;
  }
}

enum AppointmentSortBy {
  dateTime,
  doctor,
  specialty,
  type,
  status,
  location,
  duration,
  createdAt,
}

enum AppointmentQuickFilter {
  today,
  tomorrow,
  thisWeek,
  nextWeek,
  thisMonth,
  nextMonth,
  upcoming,
  past,
  cancelled,
  completed,
}

// State classes for appointment analytics
class AppointmentStats {
  final int totalAppointments;
  final int upcomingCount;
  final int todayCount;
  final int thisWeekCount;
  final int completedCount;
  final int cancelledCount;
  final int missedCount;
  final Map<AppointmentType, int> typeBreakdown;
  final Map<AppointmentStatus, int> statusBreakdown;
  final Map<String, int> doctorBreakdown;
  final Map<String, int> specialtyBreakdown;
  final Map<String, int> locationBreakdown;
  final double averageDuration;
  final int totalDuration;
  final List<AppointmentModel> upcomingAppointments;
  final List<AppointmentModel> overdueAppointments;
  final double attendanceRate;

  const AppointmentStats({
    required this.totalAppointments,
    required this.upcomingCount,
    required this.todayCount,
    required this.thisWeekCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.missedCount,
    required this.typeBreakdown,
    required this.statusBreakdown,
    required this.doctorBreakdown,
    required this.specialtyBreakdown,
    required this.locationBreakdown,
    required this.averageDuration,
    required this.totalDuration,
    required this.upcomingAppointments,
    required this.overdueAppointments,
    required this.attendanceRate,
  });
}

// Riverpod providers for appointment filtering
class AppointmentFilterNotifier extends StateNotifier<AppointmentFilter> {
  AppointmentFilterNotifier() : super(const AppointmentFilter());

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void toggleType(AppointmentType type) {
    final currentTypes = List<AppointmentType>.from(state.selectedTypes);
    if (currentTypes.contains(type)) {
      currentTypes.remove(type);
    } else {
      currentTypes.add(type);
    }
    state = state.copyWith(selectedTypes: currentTypes);
  }

  void setTypes(List<AppointmentType> types) {
    state = state.copyWith(selectedTypes: types);
  }

  void toggleStatus(AppointmentStatus status) {
    final currentStatuses = List<AppointmentStatus>.from(
      state.selectedStatuses,
    );
    if (currentStatuses.contains(status)) {
      currentStatuses.remove(status);
    } else {
      currentStatuses.add(status);
    }
    state = state.copyWith(selectedStatuses: currentStatuses);
  }

  void setStatuses(List<AppointmentStatus> statuses) {
    state = state.copyWith(selectedStatuses: statuses);
  }

  void toggleDoctor(String doctor) {
    final currentDoctors = List<String>.from(state.selectedDoctors);
    if (currentDoctors.contains(doctor)) {
      currentDoctors.remove(doctor);
    } else {
      currentDoctors.add(doctor);
    }
    state = state.copyWith(selectedDoctors: currentDoctors);
  }

  void setDoctors(List<String> doctors) {
    state = state.copyWith(selectedDoctors: doctors);
  }

  void toggleSpecialty(String specialty) {
    final currentSpecialties = List<String>.from(state.selectedSpecialties);
    if (currentSpecialties.contains(specialty)) {
      currentSpecialties.remove(specialty);
    } else {
      currentSpecialties.add(specialty);
    }
    state = state.copyWith(selectedSpecialties: currentSpecialties);
  }

  void setSpecialties(List<String> specialties) {
    state = state.copyWith(selectedSpecialties: specialties);
  }

  void toggleLocation(String location) {
    final currentLocations = List<String>.from(state.selectedLocations);
    if (currentLocations.contains(location)) {
      currentLocations.remove(location);
    } else {
      currentLocations.add(location);
    }
    state = state.copyWith(selectedLocations: currentLocations);
  }

  void setLocations(List<String> locations) {
    state = state.copyWith(selectedLocations: locations);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(AppointmentSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSortOrder(bool isAscending) {
    state = state.copyWith(isAscending: isAscending);
  }

  void toggleSortOrder() {
    state = state.copyWith(isAscending: !state.isAscending);
  }

  void setShowUpcomingOnly(bool value) {
    state = state.copyWith(showUpcomingOnly: value);
  }

  void setShowTodayOnly(bool value) {
    state = state.copyWith(showTodayOnly: value);
  }

  void setReminderThreshold(int? minutes) {
    state = state.copyWith(reminderThreshold: minutes);
  }

  void clearFilters() {
    state = const AppointmentFilter();
  }

  void setQuickFilter(AppointmentQuickFilter quickFilter) {
    final now = DateTime.now();
    switch (quickFilter) {
      case AppointmentQuickFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        state = state.copyWith(
          startDate: today,
          endDate: tomorrow,
          showTodayOnly: true,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.tomorrow:
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final dayAfterTomorrow = tomorrow.add(const Duration(days: 1));
        state = state.copyWith(
          startDate: tomorrow,
          endDate: dayAfterTomorrow,
          showTodayOnly: false,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        state = state.copyWith(
          startDate: startOfWeek,
          endDate: endOfWeek,
          showTodayOnly: false,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.nextWeek:
        final startOfNextWeek = now.add(Duration(days: 7 - now.weekday + 1));
        final endOfNextWeek = startOfNextWeek.add(const Duration(days: 7));
        state = state.copyWith(
          startDate: startOfNextWeek,
          endDate: endOfNextWeek,
          showTodayOnly: false,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        state = state.copyWith(
          startDate: startOfMonth,
          endDate: endOfMonth,
          showTodayOnly: false,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.nextMonth:
        final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
        final endOfNextMonth = DateTime(now.year, now.month + 2, 1);
        state = state.copyWith(
          startDate: startOfNextMonth,
          endDate: endOfNextMonth,
          showTodayOnly: false,
          showUpcomingOnly: false,
        );
        break;
      case AppointmentQuickFilter.upcoming:
        state = state.copyWith(
          startDate: now,
          endDate: null,
          showUpcomingOnly: true,
          showTodayOnly: false,
        );
        break;
      case AppointmentQuickFilter.past:
        state = state.copyWith(
          startDate: null,
          endDate: now,
          showUpcomingOnly: false,
          showTodayOnly: false,
        );
        break;
      case AppointmentQuickFilter.cancelled:
        state = state.copyWith(
          selectedStatuses: [AppointmentStatus.cancelled],
          showUpcomingOnly: false,
          showTodayOnly: false,
        );
        break;
      case AppointmentQuickFilter.completed:
        state = state.copyWith(
          selectedStatuses: [AppointmentStatus.completed],
          showUpcomingOnly: false,
          showTodayOnly: false,
        );
        break;
    }
  }
}

// Provider definitions
final appointmentFilterProvider =
    StateNotifierProvider<AppointmentFilterNotifier, AppointmentFilter>((ref) {
      return AppointmentFilterNotifier();
    });

// Filtered appointments provider
final filteredAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  // This would typically get data from your existing AppointmentsProvider
  final filter = ref.watch(appointmentFilterProvider);

  // TODO: Integrate with your existing AppointmentsProvider
  // final appointmentsProvider = ref.watch(appointmentsProvider);
  final List<AppointmentModel> allAppointments = []; // Replace with actual data

  return _filterAndSortAppointments(allAppointments, filter);
});

// Appointment statistics provider
final appointmentStatsProvider = Provider<AppointmentStats>((ref) {
  final filteredAppointments = ref.watch(filteredAppointmentsProvider);
  return _calculateAppointmentStats(filteredAppointments);
});

// Available doctors provider (for filter UI)
final availableDoctorsProvider = Provider<List<String>>((ref) {
  final filteredAppointments = ref.watch(filteredAppointmentsProvider);
  final doctors = <String>{};

  for (final appointment in filteredAppointments) {
    doctors.add(appointment.doctorName);
  }

  return doctors.toList()..sort();
});

// Available specialties provider (for filter UI)
final availableSpecialtiesProvider = Provider<List<String>>((ref) {
  final filteredAppointments = ref.watch(filteredAppointmentsProvider);
  final specialties = <String>{};

  for (final appointment in filteredAppointments) {
    specialties.add(appointment.specialty);
  }

  return specialties.toList()..sort();
});

// Available locations provider (for filter UI)
final availableLocationsProvider = Provider<List<String>>((ref) {
  final filteredAppointments = ref.watch(filteredAppointmentsProvider);
  final locations = <String>{};

  for (final appointment in filteredAppointments) {
    locations.add(appointment.location);
  }

  return locations.toList()..sort();
});

// Upcoming appointments provider (next 7 days)
final upcomingAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final allAppointments = ref.watch(filteredAppointmentsProvider);
  final now = DateTime.now();
  final sevenDaysFromNow = now.add(const Duration(days: 7));

  return allAppointments
      .where(
        (appointment) =>
            appointment.dateTime.isAfter(now) &&
            appointment.dateTime.isBefore(sevenDaysFromNow) &&
            appointment.status.isActive,
      )
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
});

// Overdue appointments provider
final overdueAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final allAppointments = ref.watch(filteredAppointmentsProvider);
  final now = DateTime.now();

  return allAppointments
      .where(
        (appointment) =>
            appointment.dateTime.isBefore(now) &&
            appointment.status == AppointmentStatus.scheduled,
      )
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
});

// Today's appointments provider
final todaysAppointmentsProvider = Provider<List<AppointmentModel>>((ref) {
  final allAppointments = ref.watch(filteredAppointmentsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return allAppointments
      .where(
        (appointment) =>
            appointment.dateTime.isAfter(today) &&
            appointment.dateTime.isBefore(tomorrow),
      )
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
});

// Appointment search provider
final appointmentSearchProvider =
    Provider.family<List<AppointmentModel>, String>((ref, query) {
      final allAppointments = ref.watch(filteredAppointmentsProvider);

      if (query.isEmpty) return allAppointments;

      final lowercaseQuery = query.toLowerCase();
      return allAppointments.where((appointment) {
        return appointment.title.toLowerCase().contains(lowercaseQuery) ||
            appointment.doctorName.toLowerCase().contains(lowercaseQuery) ||
            appointment.specialty.toLowerCase().contains(lowercaseQuery) ||
            appointment.location.toLowerCase().contains(lowercaseQuery) ||
            appointment.description.toLowerCase().contains(lowercaseQuery) ||
            appointment.notes.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });

// Appointments requiring reminder provider
final appointmentsNeedingReminderProvider = Provider<List<AppointmentModel>>((
  ref,
) {
  final allAppointments = ref.watch(filteredAppointmentsProvider);
  final now = DateTime.now();

  return allAppointments.where((appointment) {
    if (!appointment.isReminderSet || !appointment.status.isActive)
      return false;

    final reminderTime = appointment.dateTime.subtract(
      Duration(minutes: appointment.reminderMinutes),
    );

    return now.isAfter(reminderTime) && now.isBefore(appointment.dateTime);
  }).toList();
});

// Conflicting appointments provider
final conflictingAppointmentsProvider = Provider<List<List<AppointmentModel>>>((
  ref,
) {
  final allAppointments = ref.watch(filteredAppointmentsProvider);
  final List<List<AppointmentModel>> conflicts = [];

  for (int i = 0; i < allAppointments.length; i++) {
    final appointment1 = allAppointments[i];
    final List<AppointmentModel> conflictGroup = [appointment1];

    for (int j = i + 1; j < allAppointments.length; j++) {
      final appointment2 = allAppointments[j];

      if (AppointmentUtils.hasConflict(appointment1, [appointment2])) {
        conflictGroup.add(appointment2);
      }
    }

    if (conflictGroup.length > 1) {
      conflicts.add(conflictGroup);
    }
  }

  return conflicts;
});

// Calendar view provider (appointments grouped by date)
final appointmentCalendarProvider =
    Provider<Map<DateTime, List<AppointmentModel>>>((ref) {
      final allAppointments = ref.watch(filteredAppointmentsProvider);
      final Map<DateTime, List<AppointmentModel>> calendar = {};

      for (final appointment in allAppointments) {
        final dateKey = DateTime(
          appointment.dateTime.year,
          appointment.dateTime.month,
          appointment.dateTime.day,
        );

        if (!calendar.containsKey(dateKey)) {
          calendar[dateKey] = [];
        }
        calendar[dateKey]!.add(appointment);
      }

      // Sort appointments within each day
      for (final appointments in calendar.values) {
        appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }

      return calendar;
    });

// Helper functions
List<AppointmentModel> _filterAndSortAppointments(
  List<AppointmentModel> appointments,
  AppointmentFilter filter,
) {
  List<AppointmentModel> filtered = List.from(appointments);

  // Apply date range filter
  if (filter.startDate != null) {
    filtered = filtered
        .where((app) => app.dateTime.isAfter(filter.startDate!))
        .toList();
  }

  if (filter.endDate != null) {
    filtered = filtered
        .where((app) => app.dateTime.isBefore(filter.endDate!))
        .toList();
  }

  // Apply type filter
  if (filter.selectedTypes.isNotEmpty) {
    filtered = filtered
        .where((app) => filter.selectedTypes.contains(app.type))
        .toList();
  }

  // Apply status filter
  if (filter.selectedStatuses.isNotEmpty) {
    filtered = filtered
        .where((app) => filter.selectedStatuses.contains(app.status))
        .toList();
  }

  // Apply doctor filter
  if (filter.selectedDoctors.isNotEmpty) {
    filtered = filtered
        .where((app) => filter.selectedDoctors.contains(app.doctorName))
        .toList();
  }

  // Apply specialty filter
  if (filter.selectedSpecialties.isNotEmpty) {
    filtered = filtered
        .where((app) => filter.selectedSpecialties.contains(app.specialty))
        .toList();
  }

  // Apply location filter
  if (filter.selectedLocations.isNotEmpty) {
    filtered = filtered
        .where((app) => filter.selectedLocations.contains(app.location))
        .toList();
  }

  // Apply upcoming only filter
  if (filter.showUpcomingOnly) {
    final now = DateTime.now();
    filtered = filtered.where((app) => app.dateTime.isAfter(now)).toList();
  }

  // Apply today only filter
  if (filter.showTodayOnly) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    filtered = filtered
        .where(
          (app) =>
              app.dateTime.isAfter(today) && app.dateTime.isBefore(tomorrow),
        )
        .toList();
  }

  // Apply reminder threshold filter
  if (filter.reminderThreshold != null) {
    final now = DateTime.now();
    final threshold = now.add(Duration(minutes: filter.reminderThreshold!));
    filtered = filtered
        .where((app) => app.isReminderSet && app.dateTime.isBefore(threshold))
        .toList();
  }

  // Apply search query
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    filtered = filtered.where((app) {
      return app.title.toLowerCase().contains(query) ||
          app.doctorName.toLowerCase().contains(query) ||
          app.specialty.toLowerCase().contains(query) ||
          app.location.toLowerCase().contains(query) ||
          app.description.toLowerCase().contains(query) ||
          app.notes.toLowerCase().contains(query);
    }).toList();
  }

  // Apply sorting
  switch (filter.sortBy) {
    case AppointmentSortBy.dateTime:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.dateTime.compareTo(b.dateTime)
            : b.dateTime.compareTo(a.dateTime),
      );
      break;
    case AppointmentSortBy.doctor:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.doctorName.compareTo(b.doctorName)
            : b.doctorName.compareTo(a.doctorName),
      );
      break;
    case AppointmentSortBy.specialty:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.specialty.compareTo(b.specialty)
            : b.specialty.compareTo(a.specialty),
      );
      break;
    case AppointmentSortBy.type:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.type.displayName.compareTo(b.type.displayName)
            : b.type.displayName.compareTo(a.type.displayName),
      );
      break;
    case AppointmentSortBy.status:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.status.displayName.compareTo(b.status.displayName)
            : b.status.displayName.compareTo(a.status.displayName),
      );
      break;
    case AppointmentSortBy.location:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.location.compareTo(b.location)
            : b.location.compareTo(a.location),
      );
      break;
    case AppointmentSortBy.duration:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.duration.compareTo(b.duration)
            : b.duration.compareTo(a.duration),
      );
      break;
    case AppointmentSortBy.createdAt:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt),
      );
      break;
  }

  return filtered;
}

AppointmentStats _calculateAppointmentStats(
  List<AppointmentModel> appointments,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final endOfWeek = today.add(Duration(days: 7 - now.weekday));

  int upcomingCount = 0;
  int todayCount = 0;
  int thisWeekCount = 0;
  int completedCount = 0;
  int cancelledCount = 0;
  int missedCount = 0;

  final Map<AppointmentType, int> typeBreakdown = {};
  final Map<AppointmentStatus, int> statusBreakdown = {};
  final Map<String, int> doctorBreakdown = {};
  final Map<String, int> specialtyBreakdown = {};
  final Map<String, int> locationBreakdown = {};

  final List<AppointmentModel> upcomingAppointments = [];
  final List<AppointmentModel> overdueAppointments = [];

  int totalDurationMinutes = 0;
  int attendedAppointments = 0;
  int totalScheduledAppointments = 0;

  for (final appointment in appointments) {
    // Count by timing
    if (appointment.dateTime.isAfter(now)) {
      upcomingCount++;
      upcomingAppointments.add(appointment);
    }

    if (appointment.dateTime.isAfter(today) &&
        appointment.dateTime.isBefore(tomorrow)) {
      todayCount++;
    }

    if (appointment.dateTime.isAfter(today) &&
        appointment.dateTime.isBefore(endOfWeek)) {
      thisWeekCount++;
    }

    // Count by status
    switch (appointment.status) {
      case AppointmentStatus.completed:
        completedCount++;
        attendedAppointments++;
        totalScheduledAppointments++;
        break;
      case AppointmentStatus.cancelled:
        cancelledCount++;
        break;
      case AppointmentStatus.missed:
        missedCount++;
        totalScheduledAppointments++;
        break;
      case AppointmentStatus.scheduled:
      case AppointmentStatus.confirmed:
        totalScheduledAppointments++;
        if (appointment.dateTime.isBefore(now)) {
          overdueAppointments.add(appointment);
        }
        break;
      default:
        break;
    }

    // Count breakdowns
    typeBreakdown[appointment.type] =
        (typeBreakdown[appointment.type] ?? 0) + 1;
    statusBreakdown[appointment.status] =
        (statusBreakdown[appointment.status] ?? 0) + 1;
    doctorBreakdown[appointment.doctorName] =
        (doctorBreakdown[appointment.doctorName] ?? 0) + 1;
    specialtyBreakdown[appointment.specialty] =
        (specialtyBreakdown[appointment.specialty] ?? 0) + 1;
    locationBreakdown[appointment.location] =
        (locationBreakdown[appointment.location] ?? 0) + 1;

    // Calculate duration
    totalDurationMinutes += appointment.duration.inMinutes;
  }

  final double averageDuration = appointments.isNotEmpty
      ? totalDurationMinutes / appointments.length
      : 0.0;

  final double attendanceRate = totalScheduledAppointments > 0
      ? (attendedAppointments / totalScheduledAppointments) * 100
      : 0.0;

  // Sort upcoming and overdue by date
  upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  overdueAppointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));

  return AppointmentStats(
    totalAppointments: appointments.length,
    upcomingCount: upcomingCount,
    todayCount: todayCount,
    thisWeekCount: thisWeekCount,
    completedCount: completedCount,
    cancelledCount: cancelledCount,
    missedCount: missedCount,
    typeBreakdown: typeBreakdown,
    statusBreakdown: statusBreakdown,
    doctorBreakdown: doctorBreakdown,
    specialtyBreakdown: specialtyBreakdown,
    locationBreakdown: locationBreakdown,
    averageDuration: averageDuration,
    totalDuration: totalDurationMinutes,
    upcomingAppointments: upcomingAppointments.take(5).toList(),
    overdueAppointments: overdueAppointments,
    attendanceRate: attendanceRate,
  );
}
