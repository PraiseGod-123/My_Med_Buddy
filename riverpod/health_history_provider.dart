// lib/riverpod/health_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_log_model.dart';
import '../models/medication_model.dart';
import '../models/appointment_model.dart';

// State classes for health history filtering
class HealthHistoryFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<HealthLogType> selectedTypes;
  final List<String> selectedSymptoms;
  final List<String> selectedMoods;
  final String searchQuery;
  final HealthHistorySortBy sortBy;
  final bool isAscending;

  const HealthHistoryFilter({
    this.startDate,
    this.endDate,
    this.selectedTypes = const [],
    this.selectedSymptoms = const [],
    this.selectedMoods = const [],
    this.searchQuery = '',
    this.sortBy = HealthHistorySortBy.date,
    this.isAscending = false,
  });

  HealthHistoryFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<HealthLogType>? selectedTypes,
    List<String>? selectedSymptoms,
    List<String>? selectedMoods,
    String? searchQuery,
    HealthHistorySortBy? sortBy,
    bool? isAscending,
  }) {
    return HealthHistoryFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      selectedMoods: selectedMoods ?? this.selectedMoods,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }

  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        selectedTypes.isNotEmpty ||
        selectedSymptoms.isNotEmpty ||
        selectedMoods.isNotEmpty ||
        searchQuery.isNotEmpty ||
        sortBy != HealthHistorySortBy.date ||
        isAscending;
  }
}

enum HealthHistorySortBy { date, type, title, mood }

class HealthHistoryStats {
  final int totalEntries;
  final int vitalsCount;
  final int symptomsCount;
  final int moodCount;
  final int exerciseCount;
  final int sleepCount;
  final int generalCount;
  final Map<String, int> symptomFrequency;
  final Map<String, int> moodFrequency;
  final Map<DateTime, int> dailyEntries;
  final double averageEntriesPerDay;
  final List<String> mostCommonSymptoms;
  final List<String> mostCommonMoods;

  const HealthHistoryStats({
    required this.totalEntries,
    required this.vitalsCount,
    required this.symptomsCount,
    required this.moodCount,
    required this.exerciseCount,
    required this.sleepCount,
    required this.generalCount,
    required this.symptomFrequency,
    required this.moodFrequency,
    required this.dailyEntries,
    required this.averageEntriesPerDay,
    required this.mostCommonSymptoms,
    required this.mostCommonMoods,
  });
}

class HealthTrend {
  final String metric;
  final List<double> values;
  final List<DateTime> dates;
  final double trend; // Positive for increasing, negative for decreasing
  final String description;

  const HealthTrend({
    required this.metric,
    required this.values,
    required this.dates,
    required this.trend,
    required this.description,
  });
}

// Riverpod providers for health history management
class HealthHistoryFilterNotifier extends StateNotifier<HealthHistoryFilter> {
  HealthHistoryFilterNotifier() : super(const HealthHistoryFilter());

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void toggleType(HealthLogType type) {
    final currentTypes = List<HealthLogType>.from(state.selectedTypes);
    if (currentTypes.contains(type)) {
      currentTypes.remove(type);
    } else {
      currentTypes.add(type);
    }
    state = state.copyWith(selectedTypes: currentTypes);
  }

  void setTypes(List<HealthLogType> types) {
    state = state.copyWith(selectedTypes: types);
  }

  void toggleSymptom(String symptom) {
    final currentSymptoms = List<String>.from(state.selectedSymptoms);
    if (currentSymptoms.contains(symptom)) {
      currentSymptoms.remove(symptom);
    } else {
      currentSymptoms.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: currentSymptoms);
  }

  void setSymptoms(List<String> symptoms) {
    state = state.copyWith(selectedSymptoms: symptoms);
  }

  void toggleMood(String mood) {
    final currentMoods = List<String>.from(state.selectedMoods);
    if (currentMoods.contains(mood)) {
      currentMoods.remove(mood);
    } else {
      currentMoods.add(mood);
    }
    state = state.copyWith(selectedMoods: currentMoods);
  }

  void setMoods(List<String> moods) {
    state = state.copyWith(selectedMoods: moods);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(HealthHistorySortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSortOrder(bool isAscending) {
    state = state.copyWith(isAscending: isAscending);
  }

  void toggleSortOrder() {
    state = state.copyWith(isAscending: !state.isAscending);
  }

  void clearFilters() {
    state = const HealthHistoryFilter();
  }

  void setQuickFilter(HealthHistoryQuickFilter quickFilter) {
    final now = DateTime.now();
    switch (quickFilter) {
      case HealthHistoryQuickFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        state = state.copyWith(startDate: today, endDate: tomorrow);
        break;
      case HealthHistoryQuickFilter.yesterday:
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final today = DateTime(now.year, now.month, now.day);
        state = state.copyWith(startDate: yesterday, endDate: today);
        break;
      case HealthHistoryQuickFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        state = state.copyWith(startDate: startOfWeek, endDate: endOfWeek);
        break;
      case HealthHistoryQuickFilter.lastWeek:
        final startOfLastWeek = now.subtract(Duration(days: now.weekday + 6));
        final endOfLastWeek = startOfLastWeek.add(const Duration(days: 7));
        state = state.copyWith(
          startDate: startOfLastWeek,
          endDate: endOfLastWeek,
        );
        break;
      case HealthHistoryQuickFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        state = state.copyWith(startDate: startOfMonth, endDate: endOfMonth);
        break;
      case HealthHistoryQuickFilter.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final endOfLastMonth = DateTime(now.year, now.month, 1);
        state = state.copyWith(
          startDate: startOfLastMonth,
          endDate: endOfLastMonth,
        );
        break;
      case HealthHistoryQuickFilter.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        state = state.copyWith(startDate: thirtyDaysAgo, endDate: now);
        break;
      case HealthHistoryQuickFilter.last90Days:
        final ninetyDaysAgo = now.subtract(const Duration(days: 90));
        state = state.copyWith(startDate: ninetyDaysAgo, endDate: now);
        break;
    }
  }
}

enum HealthHistoryQuickFilter {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last30Days,
  last90Days,
}

// Provider definitions
final healthHistoryFilterProvider =
    StateNotifierProvider<HealthHistoryFilterNotifier, HealthHistoryFilter>((
      ref,
    ) {
      return HealthHistoryFilterNotifier();
    });

// Filtered health logs provider
final filteredHealthLogsProvider = Provider<List<HealthLogModel>>((ref) {
  // This would typically get data from your existing HealthLogsProvider
  // For now, we'll return an empty list - you'll need to integrate with your existing provider
  final filter = ref.watch(healthHistoryFilterProvider);

  // TODO: Integrate with your existing HealthLogsProvider
  // final healthLogsProvider = ref.watch(healthLogsProvider);
  final List<HealthLogModel> allLogs = []; // Replace with actual data

  return _filterAndSortLogs(allLogs, filter);
});

// Health history statistics provider
final healthHistoryStatsProvider = Provider<HealthHistoryStats>((ref) {
  final filteredLogs = ref.watch(filteredHealthLogsProvider);
  return _calculateStats(filteredLogs);
});

// Health trends provider
final healthTrendsProvider = Provider<List<HealthTrend>>((ref) {
  final filteredLogs = ref.watch(filteredHealthLogsProvider);
  return _calculateTrends(filteredLogs);
});

// Available symptoms provider (for filter UI)
final availableSymptomsProvider = Provider<List<String>>((ref) {
  final filteredLogs = ref.watch(filteredHealthLogsProvider);
  final symptoms = <String>{};

  for (final log in filteredLogs) {
    symptoms.addAll(log.symptoms);
  }

  return symptoms.toList()..sort();
});

// Available moods provider (for filter UI)
final availableMoodsProvider = Provider<List<String>>((ref) {
  final filteredLogs = ref.watch(filteredHealthLogsProvider);
  final moods = <String>{};

  for (final log in filteredLogs) {
    if (log.mood != null) {
      moods.add(log.mood!);
    }
  }

  return moods.toList()..sort();
});

// Recent health logs provider (last 7 days)
final recentHealthLogsProvider = Provider<List<HealthLogModel>>((ref) {
  final allLogs = ref.watch(filteredHealthLogsProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return allLogs.where((log) => log.date.isAfter(sevenDaysAgo)).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

// Health log search provider
final healthLogSearchProvider = Provider.family<List<HealthLogModel>, String>((
  ref,
  query,
) {
  final allLogs = ref.watch(filteredHealthLogsProvider);

  if (query.isEmpty) return allLogs;

  final lowercaseQuery = query.toLowerCase();
  return allLogs.where((log) {
    return log.title.toLowerCase().contains(lowercaseQuery) ||
        log.description.toLowerCase().contains(lowercaseQuery) ||
        log.symptoms.any(
          (symptom) => symptom.toLowerCase().contains(lowercaseQuery),
        ) ||
        (log.mood?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        (log.notes?.toLowerCase().contains(lowercaseQuery) ?? false);
  }).toList();
});

// Helper functions
List<HealthLogModel> _filterAndSortLogs(
  List<HealthLogModel> logs,
  HealthHistoryFilter filter,
) {
  List<HealthLogModel> filtered = List.from(logs);

  // Apply date range filter
  if (filter.startDate != null) {
    filtered = filtered
        .where((log) => log.date.isAfter(filter.startDate!))
        .toList();
  }

  if (filter.endDate != null) {
    filtered = filtered
        .where((log) => log.date.isBefore(filter.endDate!))
        .toList();
  }

  // Apply type filter
  if (filter.selectedTypes.isNotEmpty) {
    filtered = filtered
        .where((log) => filter.selectedTypes.contains(log.type))
        .toList();
  }

  // Apply symptom filter
  if (filter.selectedSymptoms.isNotEmpty) {
    filtered = filtered.where((log) {
      return filter.selectedSymptoms.any(
        (symptom) => log.symptoms.contains(symptom),
      );
    }).toList();
  }

  // Apply mood filter
  if (filter.selectedMoods.isNotEmpty) {
    filtered = filtered.where((log) {
      return log.mood != null && filter.selectedMoods.contains(log.mood!);
    }).toList();
  }

  // Apply search query
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    filtered = filtered.where((log) {
      return log.title.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query) ||
          log.symptoms.any(
            (symptom) => symptom.toLowerCase().contains(query),
          ) ||
          (log.mood?.toLowerCase().contains(query) ?? false) ||
          (log.notes?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // Apply sorting
  switch (filter.sortBy) {
    case HealthHistorySortBy.date:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date),
      );
      break;
    case HealthHistorySortBy.type:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.type.displayName.compareTo(b.type.displayName)
            : b.type.displayName.compareTo(a.type.displayName),
      );
      break;
    case HealthHistorySortBy.title:
      filtered.sort(
        (a, b) => filter.isAscending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title),
      );
      break;
    case HealthHistorySortBy.mood:
      filtered.sort((a, b) {
        final aMood = a.mood ?? '';
        final bMood = b.mood ?? '';
        return filter.isAscending
            ? aMood.compareTo(bMood)
            : bMood.compareTo(aMood);
      });
      break;
  }

  return filtered;
}

HealthHistoryStats _calculateStats(List<HealthLogModel> logs) {
  final Map<String, int> symptomFrequency = {};
  final Map<String, int> moodFrequency = {};
  final Map<DateTime, int> dailyEntries = {};

  int vitalsCount = 0;
  int symptomsCount = 0;
  int moodCount = 0;
  int exerciseCount = 0;
  int sleepCount = 0;
  int generalCount = 0;

  for (final log in logs) {
    // Count by type
    switch (log.type) {
      case HealthLogType.vitals:
        vitalsCount++;
        break;
      case HealthLogType.symptoms:
        symptomsCount++;
        break;
      case HealthLogType.mood:
        moodCount++;
        break;
      case HealthLogType.exercise:
        exerciseCount++;
        break;
      case HealthLogType.sleep:
        sleepCount++;
        break;
      case HealthLogType.general:
        generalCount++;
        break;
    }

    // Count symptoms
    for (final symptom in log.symptoms) {
      symptomFrequency[symptom] = (symptomFrequency[symptom] ?? 0) + 1;
    }

    // Count moods
    if (log.mood != null) {
      moodFrequency[log.mood!] = (moodFrequency[log.mood!] ?? 0) + 1;
    }

    // Count daily entries
    final dateKey = DateTime(log.date.year, log.date.month, log.date.day);
    dailyEntries[dateKey] = (dailyEntries[dateKey] ?? 0) + 1;
  }

  // Calculate average entries per day
  final double averageEntriesPerDay = dailyEntries.isNotEmpty
      ? dailyEntries.values.reduce((a, b) => a + b) / dailyEntries.length
      : 0.0;

  // Get most common symptoms and moods
  final mostCommonSymptoms = symptomFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final mostCommonMoods = moodFrequency.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return HealthHistoryStats(
    totalEntries: logs.length,
    vitalsCount: vitalsCount,
    symptomsCount: symptomsCount,
    moodCount: moodCount,
    exerciseCount: exerciseCount,
    sleepCount: sleepCount,
    generalCount: generalCount,
    symptomFrequency: symptomFrequency,
    moodFrequency: moodFrequency,
    dailyEntries: dailyEntries,
    averageEntriesPerDay: averageEntriesPerDay,
    mostCommonSymptoms: mostCommonSymptoms.take(5).map((e) => e.key).toList(),
    mostCommonMoods: mostCommonMoods.take(5).map((e) => e.key).toList(),
  );
}

List<HealthTrend> _calculateTrends(List<HealthLogModel> logs) {
  final List<HealthTrend> trends = [];

  // Calculate vital signs trends
  final vitalsLogs = logs
      .where((log) => log.type == HealthLogType.vitals)
      .toList();
  if (vitalsLogs.isNotEmpty) {
    // Blood pressure trend
    final bpValues = vitalsLogs
        .where((log) => log.metrics.containsKey('blood_pressure_systolic'))
        .map((log) {
          final value = log.metrics['blood_pressure_systolic'];
          return value is int ? value.toDouble() : (value as double);
        })
        .toList();

    if (bpValues.length >= 2) {
      final bpDates = vitalsLogs
          .where((log) => log.metrics.containsKey('blood_pressure_systolic'))
          .map((log) => log.date)
          .toList();

      final bpTrend = _calculateTrendValue(bpValues);
      trends.add(
        HealthTrend(
          metric: 'Blood Pressure (Systolic)',
          values: bpValues,
          dates: bpDates,
          trend: bpTrend,
          description: _getTrendDescription(bpTrend, 'blood pressure'),
        ),
      );
    }

    // Heart rate trend
    final hrValues = vitalsLogs
        .where((log) => log.metrics.containsKey('heart_rate'))
        .map((log) {
          final value = log.metrics['heart_rate'];
          return value is int ? value.toDouble() : (value as double);
        })
        .toList();

    if (hrValues.length >= 2) {
      final hrDates = vitalsLogs
          .where((log) => log.metrics.containsKey('heart_rate'))
          .map((log) => log.date)
          .toList();

      final hrTrend = _calculateTrendValue(hrValues);
      trends.add(
        HealthTrend(
          metric: 'Heart Rate',
          values: hrValues,
          dates: hrDates,
          trend: hrTrend,
          description: _getTrendDescription(hrTrend, 'heart rate'),
        ),
      );
    }
  }

  // Calculate mood trends
  final moodLogs = logs.where((log) => log.mood != null).toList();
  if (moodLogs.isNotEmpty) {
    final moodValues = moodLogs.map((log) => _moodToValue(log.mood!)).toList();
    final moodDates = moodLogs.map((log) => log.date).toList();

    if (moodValues.length >= 2) {
      final moodTrend = _calculateTrendValue(moodValues);
      trends.add(
        HealthTrend(
          metric: 'Mood',
          values: moodValues,
          dates: moodDates,
          trend: moodTrend,
          description: _getTrendDescription(moodTrend, 'mood'),
        ),
      );
    }
  }

  return trends;
}

double _calculateTrendValue(List<double> values) {
  if (values.length < 2) return 0.0;

  final n = values.length;
  final xSum = n * (n - 1) / 2;
  final ySum = values.reduce((a, b) => a + b);
  final xySum = values.asMap().entries.fold(
    0.0,
    (sum, entry) => sum + entry.key * entry.value,
  );
  final xSquaredSum = n * (n - 1) * (2 * n - 1) / 6;

  final slope = (n * xySum - xSum * ySum) / (n * xSquaredSum - xSum * xSum);
  return slope;
}

double _moodToValue(String mood) {
  switch (mood.toLowerCase()) {
    case 'terrible':
      return 1.0;
    case 'poor':
      return 2.0;
    case 'fair':
      return 3.0;
    case 'good':
      return 4.0;
    case 'excellent':
      return 5.0;
    default:
      return 3.0;
  }
}

String _getTrendDescription(double trend, String metric) {
  if (trend > 0.1) {
    return 'Your $metric is showing an increasing trend';
  } else if (trend < -0.1) {
    return 'Your $metric is showing a decreasing trend';
  } else {
    return 'Your $metric is relatively stable';
  }
}
