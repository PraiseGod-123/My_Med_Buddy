// lib/riverpod/medication_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_model.dart';

// State class for medication filtering
class MedicationFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedFrequencies;
  final List<String> selectedColors;
  final List<String> selectedNames;
  final String searchQuery;
  final MedicationSortBy sortBy;
  final bool isAscending;
  final bool showActiveOnly;
  final bool showOverdueOnly;
  final bool showTodayOnly;
  final bool hasReminders;
  final int? adherenceThreshold; // Percentage

  const MedicationFilter({
    this.startDate,
    this.endDate,
    this.selectedFrequencies = const [],
    this.selectedColors = const [],
    this.selectedNames = const [],
    this.searchQuery = '',
    this.sortBy = MedicationSortBy.name,
    this.isAscending = true,
    this.showActiveOnly = false,
    this.showOverdueOnly = false,
    this.showTodayOnly = false,
    this.hasReminders = false,
    this.adherenceThreshold,
  });

  MedicationFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedFrequencies,
    List<String>? selectedColors,
    List<String>? selectedNames,
    String? searchQuery,
    MedicationSortBy? sortBy,
    bool? isAscending,
    bool? showActiveOnly,
    bool? showOverdueOnly,
    bool? showTodayOnly,
    bool? hasReminders,
    int? adherenceThreshold,
  }) {
    return MedicationFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedFrequencies: selectedFrequencies ?? this.selectedFrequencies,
      selectedColors: selectedColors ?? this.selectedColors,
      selectedNames: selectedNames ?? this.selectedNames,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
      showActiveOnly: showActiveOnly ?? this.showActiveOnly,
      showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
      showTodayOnly: showTodayOnly ?? this.showTodayOnly,
      hasReminders: hasReminders ?? this.hasReminders,
      adherenceThreshold: adherenceThreshold ?? this.adherenceThreshold,
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        selectedFrequencies.isNotEmpty ||
        selectedColors.isNotEmpty ||
        selectedNames.isNotEmpty ||
        searchQuery.isNotEmpty ||
        sortBy != MedicationSortBy.name ||
        !isAscending ||
        showActiveOnly ||
        showOverdueOnly ||
        showTodayOnly ||
        hasReminders ||
        adherenceThreshold != null;
  }
}

enum MedicationSortBy {
  name,
  startDate,
  frequency,
  nextDose,
  adherence,
  color,
  dosage,
}

enum MedicationQuickFilter {
  active,
  inactive,
  overdue,
  today,
  thisWeek,
  onceDaily,
  twiceDaily,
  asNeeded,
  highAdherence,
  lowAdherence,
}

// State classes for medication analytics
class MedicationStats {
  final int totalMedications;
  final int activeMedications;
  final int inactiveMedications;
  final int overdueToday;
  final int scheduledToday;
  final int takenToday;
  final int missedToday;
  final Map<String, int> frequencyBreakdown;
  final Map<String, int> colorBreakdown;
  final Map<String, double> adherenceRates;
  final double overallAdherence;
  final int totalDosesScheduled;
  final int totalDosesTaken;
  final int totalDosesMissed;
  final List<MedicationModel> upcomingMedications;
  final List<MedicationModel> overdueMedications;
  final List<MedicationModel> lowAdherenceMedications;
  final int streakDays;

  const MedicationStats({
    required this.totalMedications,
    required this.activeMedications,
    required this.inactiveMedications,
    required this.overdueToday,
    required this.scheduledToday,
    required this.takenToday,
    required this.missedToday,
    required this.frequencyBreakdown,
    required this.colorBreakdown,
    required this.adherenceRates,
    required this.overallAdherence,
    required this.totalDosesScheduled,
    required this.totalDosesTaken,
    required this.totalDosesMissed,
    required this.upcomingMedications,
    required this.overdueMedications,
    required this.lowAdherenceMedications,
    required this.streakDays,
  });
}

class MedicationAdherence {
  final String medicationId;
  final String medicationName;
  final double adherenceRate;
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final int streakDays;
  final List<DateTime> missedDoses;
  final List<DateTime> takenDoses;
  final DateTime? lastTaken;
  final DateTime? nextScheduled;

  const MedicationAdherence({
    required this.medicationId,
    required this.medicationName,
    required this.adherenceRate,
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.streakDays,
    required this.missedDoses,
    required this.takenDoses,
    this.lastTaken,
    this.nextScheduled,
  });
}

// Riverpod providers for medication filtering
class MedicationFilterNotifier extends StateNotifier<MedicationFilter> {
  MedicationFilterNotifier() : super(const MedicationFilter());

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void toggleFrequency(String frequency) {
    final currentFrequencies = List<String>.from(state.selectedFrequencies);
    if (currentFrequencies.contains(frequency)) {
      currentFrequencies.remove(frequency);
    } else {
      currentFrequencies.add(frequency);
    }
    state = state.copyWith(selectedFrequencies: currentFrequencies);
  }

  void setFrequencies(List<String> frequencies) {
    state = state.copyWith(selectedFrequencies: frequencies);
  }

  void toggleColor(String color) {
    final currentColors = List<String>.from(state.selectedColors);
    if (currentColors.contains(color)) {
      currentColors.remove(color);
    } else {
      currentColors.add(color);
    }
    state = state.copyWith(selectedColors: currentColors);
  }

  void setColors(List<String> colors) {
    state = state.copyWith(selectedColors: colors);
  }

  void toggleMedication(String medicationName) {
    final currentNames = List<String>.from(state.selectedNames);
    if (currentNames.contains(medicationName)) {
      currentNames.remove(medicationName);
    } else {
      currentNames.add(medicationName);
    }
    state = state.copyWith(selectedNames: currentNames);
  }

  void setMedications(List<String> names) {
    state = state.copyWith(selectedNames: names);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(MedicationSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSortOrder(bool isAscending) {
    state = state.copyWith(isAscending: isAscending);
  }

  void toggleSortOrder() {
    state = state.copyWith(isAscending: !state.isAscending);
  }

  void setShowActiveOnly(bool value) {
    state = state.copyWith(showActiveOnly: value);
  }

  void setShowOverdueOnly(bool value) {
    state = state.copyWith(showOverdueOnly: value);
  }

  void setShowTodayOnly(bool value) {
    state = state.copyWith(showTodayOnly: value);
  }

  void setHasReminders(bool value) {
    state = state.copyWith(hasReminders: value);
  }

  void setAdherenceThreshold(int? threshold) {
    state = state.copyWith(adherenceThreshold: threshold);
  }

  void clearFilters() {
    state = const MedicationFilter();
  }

  void setQuickFilter(MedicationQuickFilter quickFilter) {
    switch (quickFilter) {
      case MedicationQuickFilter.active:
        state = state.copyWith(
          showActiveOnly: true,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.inactive:
        state = state.copyWith(
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.overdue:
        state = state.copyWith(
          showOverdueOnly: true,
          showActiveOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.today:
        state = state.copyWith(
          showTodayOnly: true,
          showActiveOnly: false,
          showOverdueOnly: false,
        );
        break;
      case MedicationQuickFilter.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        state = state.copyWith(
          startDate: startOfWeek,
          endDate: endOfWeek,
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.onceDaily:
        state = state.copyWith(
          selectedFrequencies: ['Once daily'],
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.twiceDaily:
        state = state.copyWith(
          selectedFrequencies: ['Twice daily'],
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.asNeeded:
        state = state.copyWith(
          selectedFrequencies: ['As needed'],
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.highAdherence:
        state = state.copyWith(
          adherenceThreshold: 90,
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
      case MedicationQuickFilter.lowAdherence:
        state = state.copyWith(
          adherenceThreshold: 70,
          showActiveOnly: false,
          showOverdueOnly: false,
          showTodayOnly: false,
        );
        break;
    }
  }
}

// Provider definitions
final medicationFilterProvider =
    StateNotifierProvider<MedicationFilterNotifier, MedicationFilter>((ref) {
      return MedicationFilterNotifier();
    });

// Filtered medications provider
final filteredMedicationsProvider = Provider<List<MedicationModel>>((ref) {
  // This would typically get data from your existing MedicationProvider
  final filter = ref.watch(medicationFilterProvider);

  // TODO: Integrate with your existing MedicationProvider
  // final medicationProvider = ref.watch(medicationProvider);
  final List<MedicationModel> allMedications = []; // Replace with actual data

  return _filterAndSortMedications(allMedications, filter);
});

// Medication statistics provider
final medicationStatsProvider = Provider<MedicationStats>((ref) {
  final filteredMedications = ref.watch(filteredMedicationsProvider);
  return _calculateMedicationStats(filteredMedications);
});

// Medication adherence provider
final medicationAdherenceProvider = Provider<List<MedicationAdherence>>((ref) {
  final filteredMedications = ref.watch(filteredMedicationsProvider);
  return _calculateMedicationAdherence(filteredMedications);
});

// Available frequencies provider (for filter UI)
final availableFrequenciesProvider = Provider<List<String>>((ref) {
  final filteredMedications = ref.watch(filteredMedicationsProvider);
  final frequencies = <String>{};

  for (final medication in filteredMedications) {
    frequencies.add(medication.frequency);
  }

  return frequencies.toList()..sort();
});

// Available colors provider (for filter UI)
final availableColorsProvider = Provider<List<String>>((ref) {
  final filteredMedications = ref.watch(filteredMedicationsProvider);
  final colors = <String>{};

  for (final medication in filteredMedications) {
    colors.add(medication.color);
  }

  return colors.toList()..sort();
});

// Active medications provider
final activeMedicationsProvider = Provider<List<MedicationModel>>((ref) {
  final allMedications = ref.watch(filteredMedicationsProvider);
  return allMedications.where((medication) => medication.isActive).toList();
});

// Today's medications provider
final todaysMedicationsProvider = Provider<List<MedicationModel>>((ref) {
  final allMedications = ref.watch(filteredMedicationsProvider);
  final now = DateTime.now();

  return allMedications.where((medication) {
    if (!medication.isActive) return false;

    // Check if medication should be taken today
    if (medication.endDate != null && medication.endDate!.isBefore(now)) {
      return false;
    }

    return medication.startDate.isBefore(now.add(const Duration(days: 1)));
  }).toList();
});

// Overdue medications provider
final overdueMedicationsProvider = Provider<List<MedicationModel>>((ref) {
  final todaysMedications = ref.watch(todaysMedicationsProvider);
  final now = DateTime.now();
  final List<MedicationModel> overdue = [];

  for (final medication in todaysMedications) {
    for (final timeStr in medication.times) {
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
        final logExists = medication.logs.any(
          (log) =>
              log.scheduledTime.day == now.day &&
              log.scheduledTime.month == now.month &&
              log.scheduledTime.year == now.year &&
              log.scheduledTime.hour == time.hour &&
              log.scheduledTime.minute == time.minute &&
              (log.isTaken || log.isSkipped),
        );

        if (!logExists && !overdue.contains(medication)) {
          overdue.add(medication);
        }
      }
    }
  }

  return overdue;
});

// Next medication provider
final nextMedicationProvider = Provider<MedicationModel?>((ref) {
  final todaysMedications = ref.watch(todaysMedicationsProvider);
  final now = DateTime.now();

  MedicationModel? nextMed;
  DateTime? nextTime;

  for (final medication in todaysMedications) {
    for (final timeStr in medication.times) {
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
          nextMed = medication;
        }
      }
    }
  }

  return nextMed;
});

// Medication search provider
final medicationSearchProvider = Provider.family<List<MedicationModel>, String>(
  (ref, query) {
    final allMedications = ref.watch(filteredMedicationsProvider);

    if (query.isEmpty) return allMedications;

    final lowercaseQuery = query.toLowerCase();
    return allMedications.where((medication) {
      return medication.name.toLowerCase().contains(lowercaseQuery) ||
          medication.dosage.toLowerCase().contains(lowercaseQuery) ||
          medication.instructions.toLowerCase().contains(lowercaseQuery) ||
          medication.frequency.toLowerCase().contains(lowercaseQuery);
    }).toList();
  },
);

// Low adherence medications provider
final lowAdherenceMedicationsProvider = Provider<List<MedicationModel>>((ref) {
  final adherenceData = ref.watch(medicationAdherenceProvider);
  const threshold = 70.0; // 70% adherence threshold

  return adherenceData
      .where((adherence) => adherence.adherenceRate < threshold)
      .map(
        (adherence) => ref
            .watch(filteredMedicationsProvider)
            .firstWhere((med) => med.id == adherence.medicationId),
      )
      .toList();
});

// Medications due soon provider (next 2 hours)
final medicationsDueSoonProvider = Provider<List<MedicationModel>>((ref) {
  final todaysMedications = ref.watch(todaysMedicationsProvider);
  final now = DateTime.now();
  final twoHoursFromNow = now.add(const Duration(hours: 2));
  final List<MedicationModel> dueSoon = [];

  for (final medication in todaysMedications) {
    for (final timeStr in medication.times) {
      final time = _parseTimeString(timeStr);
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDateTime.isAfter(now) &&
          scheduledDateTime.isBefore(twoHoursFromNow) &&
          !dueSoon.contains(medication)) {
        dueSoon.add(medication);
      }
    }
  }

  return dueSoon..sort((a, b) {
    // Sort by next dose time
    final aNextTime = _getNextDoseTime(a, now);
    final bNextTime = _getNextDoseTime(b, now);
    if (aNextTime == null && bNextTime == null) return 0;
    if (aNextTime == null) return 1;
    if (bNextTime == null) return -1;
    return aNextTime.compareTo(bNextTime);
  });
});

// Helper functions
List<MedicationModel> _filterAndSortMedications(
  List<MedicationModel> medications,
  MedicationFilter filter,
) {
  List<MedicationModel> filtered = List.from(medications);

  // Apply date range filter
  if (filter.startDate != null) {
    filtered = filtered
        .where((med) => med.startDate.isAfter(filter.startDate!))
        .toList();
  }

  if (filter.endDate != null) {
    filtered = filtered
        .where(
          (med) =>
              med.endDate == null || med.endDate!.isBefore(filter.endDate!),
        )
        .toList();
  }

  // Apply frequency filter
  if (filter.selectedFrequencies.isNotEmpty) {
    filtered = filtered
        .where((med) => filter.selectedFrequencies.contains(med.frequency))
        .toList();
  }

  // Apply color filter
  if (filter.selectedColors.isNotEmpty) {
    filtered = filtered
        .where((med) => filter.selectedColors.contains(med.color))
        .toList();
  }

  // Apply medication name filter
  if (filter.selectedNames.isNotEmpty) {
    filtered = filtered
        .where((med) => filter.selectedNames.contains(med.name))
        .toList();
  }

  // Apply active only filter
  if (filter.showActiveOnly) {
    filtered = filtered.where((med) => med.isActive).toList();
  }

  // Apply today only filter
  if (filter.showTodayOnly) {
    final now = DateTime.now();
    filtered = filtered.where((med) {
      if (!med.isActive) return false;
      if (med.endDate != null && med.endDate!.isBefore(now)) return false;
      return med.startDate.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }

  // Apply overdue only filter
  if (filter.showOverdueOnly) {
    final now = DateTime.now();
    filtered = filtered.where((med) {
      // Check if medication has overdue doses
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
          final logExists = med.logs.any(
            (log) =>
                log.scheduledTime.day == now.day &&
                log.scheduledTime.month == now.month &&
                log.scheduledTime.year == now.year &&
                log.scheduledTime.hour == time.hour &&
                log.scheduledTime.minute == time.minute &&
                (log.isTaken || log.isSkipped),
          );

          if (!logExists) return true;
        }
      }
      return false;
    }).toList();
  }

  // Apply search query
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    filtered = filtered.where((med) {
      return med.name.toLowerCase().contains(query) ||
          med.dosage.toLowerCase().contains(query) ||
          med.instructions.toLowerCase().contains(query) ||
          med.frequency.toLowerCase().contains(query);
    }).toList();
  }

  // Apply adherence threshold filter
  if (filter.adherenceThreshold != null) {
    filtered = filtered.where((med) {
      final adherence = _calculateSingleMedicationAdherence(med);
      return filter.adherenceThreshold! > 80
          ? adherence >= filter.adherenceThreshold!
          : adherence <= filter.adherenceThreshold!;
    }).toList();
  }

  // Apply sorting
  switch (filter.sortBy) {
    case MedicationSortBy.name:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name),
      );
      break;
    case MedicationSortBy.startDate:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.startDate.compareTo(b.startDate)
            : b.startDate.compareTo(a.startDate),
      );
      break;
    case MedicationSortBy.frequency:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.frequency.compareTo(b.frequency)
            : b.frequency.compareTo(a.frequency),
      );
      break;
    case MedicationSortBy.nextDose:
      final now = DateTime.now();
      filtered.sort((a, b) {
        final aNextTime = _getNextDoseTime(a, now);
        final bNextTime = _getNextDoseTime(b, now);
        if (aNextTime == null && bNextTime == null) return 0;
        if (aNextTime == null) return filter.isAscending ? 1 : -1;
        if (bNextTime == null) return filter.isAscending ? -1 : 1;
        return filter.isAscending
            ? aNextTime.compareTo(bNextTime)
            : bNextTime.compareTo(aNextTime);
      });
      break;
    case MedicationSortBy.adherence:
      filtered.sort((a, b) {
        final aAdherence = _calculateSingleMedicationAdherence(a);
        final bAdherence = _calculateSingleMedicationAdherence(b);
        return filter.isAscending
            ? aAdherence.compareTo(bAdherence)
            : bAdherence.compareTo(aAdherence);
      });
      break;
    case MedicationSortBy.color:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.color.compareTo(b.color)
            : b.color.compareTo(a.color),
      );
      break;
    case MedicationSortBy.dosage:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.dosage.compareTo(b.dosage)
            : b.dosage.compareTo(a.dosage),
      );
      break;
  }

  return filtered;
}

MedicationStats _calculateMedicationStats(List<MedicationModel> medications) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  int activeMedications = 0;
  int inactiveMedications = 0;
  int overdueToday = 0;
  int scheduledToday = 0;
  int takenToday = 0;
  int missedToday = 0;

  final Map<String, int> frequencyBreakdown = {};
  final Map<String, int> colorBreakdown = {};
  final Map<String, double> adherenceRates = {};

  final List<MedicationModel> upcomingMedications = [];
  final List<MedicationModel> overdueMedications = [];
  final List<MedicationModel> lowAdherenceMedications = [];

  int totalDosesScheduled = 0;
  int totalDosesTaken = 0;
  int totalDosesMissed = 0;

  for (final medication in medications) {
    // Count active/inactive
    if (medication.isActive) {
      activeMedications++;
    } else {
      inactiveMedications++;
    }

    // Count frequency and color breakdowns
    frequencyBreakdown[medication.frequency] =
        (frequencyBreakdown[medication.frequency] ?? 0) + 1;
    colorBreakdown[medication.color] =
        (colorBreakdown[medication.color] ?? 0) + 1;

    // Calculate adherence
    final adherence = _calculateSingleMedicationAdherence(medication);
    adherenceRates[medication.name] = adherence;

    if (adherence < 70) {
      lowAdherenceMedications.add(medication);
    }

    // Count today's doses
    if (medication.isActive) {
      for (final timeStr in medication.times) {
        final time = _parseTimeString(timeStr);
        final scheduledDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );

        scheduledToday++;
        totalDosesScheduled++;

        // Check if dose was taken
        final log = medication.logs.firstWhere(
          (log) =>
              log.scheduledTime.day == today.day &&
              log.scheduledTime.month == today.month &&
              log.scheduledTime.year == today.year &&
              log.scheduledTime.hour == time.hour &&
              log.scheduledTime.minute == time.minute,
          orElse: () => MedicationLog(
            id: '',
            medicationId: medication.id,
            scheduledTime: scheduledDateTime,
          ),
        );

        if (log.id.isNotEmpty) {
          if (log.isTaken) {
            takenToday++;
            totalDosesTaken++;
          } else if (log.isSkipped) {
            missedToday++;
            totalDosesMissed++;
          }
        } else if (scheduledDateTime.isBefore(now)) {
          overdueToday++;
          missedToday++;
          totalDosesMissed++;
          if (!overdueMedications.contains(medication)) {
            overdueMedications.add(medication);
          }
        }

        // Add to upcoming if due later today
        if (scheduledDateTime.isAfter(now) &&
            !upcomingMedications.contains(medication)) {
          upcomingMedications.add(medication);
        }
      }
    }
  }

  final double overallAdherence = totalDosesScheduled > 0
      ? (totalDosesTaken / totalDosesScheduled) * 100
      : 0.0;

  // Calculate streak days (simplified)
  int streakDays = 0;
  final checkDate = DateTime.now().subtract(const Duration(days: 1));
  // This would need more complex logic to calculate actual streak

  return MedicationStats(
    totalMedications: medications.length,
    activeMedications: activeMedications,
    inactiveMedications: inactiveMedications,
    overdueToday: overdueToday,
    scheduledToday: scheduledToday,
    takenToday: takenToday,
    missedToday: missedToday,
    frequencyBreakdown: frequencyBreakdown,
    colorBreakdown: colorBreakdown,
    adherenceRates: adherenceRates,
    overallAdherence: overallAdherence,
    totalDosesScheduled: totalDosesScheduled,
    totalDosesTaken: totalDosesTaken,
    totalDosesMissed: totalDosesMissed,
    upcomingMedications: upcomingMedications.take(5).toList(),
    overdueMedications: overdueMedications,
    lowAdherenceMedications: lowAdherenceMedications,
    streakDays: streakDays,
  );
}

List<MedicationAdherence> _calculateMedicationAdherence(
  List<MedicationModel> medications,
) {
  return medications.map((medication) {
    final adherenceRate = _calculateSingleMedicationAdherence(medication);
    final totalScheduled = medication.logs.length;
    final totalTaken = medication.logs.where((log) => log.isTaken).length;
    final totalMissed = medication.logs
        .where((log) => !log.isTaken && !log.isSkipped)
        .length;

    final missedDoses = medication.logs
        .where((log) => !log.isTaken && !log.isSkipped)
        .map((log) => log.scheduledTime)
        .toList();

    final takenDoses = medication.logs
        .where((log) => log.isTaken)
        .map((log) => log.takenTime ?? log.scheduledTime)
        .toList();

    final lastTaken = takenDoses.isNotEmpty
        ? takenDoses.reduce((a, b) => a.isAfter(b) ? a : b)
        : null;

    final nextScheduled = _getNextDoseTime(medication, DateTime.now());

    return MedicationAdherence(
      medicationId: medication.id,
      medicationName: medication.name,
      adherenceRate: adherenceRate,
      totalScheduled: totalScheduled,
      totalTaken: totalTaken,
      totalMissed: totalMissed,
      streakDays: 0, // Would need more complex calculation
      missedDoses: missedDoses,
      takenDoses: takenDoses,
      lastTaken: lastTaken,
      nextScheduled: nextScheduled,
    );
  }).toList();
}

// Helper functions
DateTime _parseTimeString(String timeStr) {
  final parts = timeStr.split(':');
  return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
}

DateTime? _getNextDoseTime(MedicationModel medication, DateTime now) {
  if (!medication.isActive) return null;

  for (final timeStr in medication.times) {
    final time = _parseTimeString(timeStr);
    final scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDateTime.isAfter(now)) {
      return scheduledDateTime;
    }
  }

  // If no time today, return first time tomorrow
  if (medication.times.isNotEmpty) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final firstTime = _parseTimeString(medication.times.first);
    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      firstTime.hour,
      firstTime.minute,
    );
  }

  return null;
}

double _calculateSingleMedicationAdherence(MedicationModel medication) {
  if (medication.logs.isEmpty) return 100.0;

  final takenCount = medication.logs.where((log) => log.isTaken).length;
  final totalCount = medication.logs.length;

  return (takenCount / totalCount) * 100;
}
