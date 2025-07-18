// lib/core/utils/date_utils.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatTimeAmPm(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  static String formatDateTimeShort(DateTime date) {
    return DateFormat('MM/dd/yyyy HH:mm').format(date);
  }

  static String formatTimeOnly(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  static String formatWeekday(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String formatWeekdayShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return AppStrings.today;
    } else if (targetDate == yesterday) {
      return AppStrings.yesterday;
    } else if (targetDate == tomorrow) {
      return AppStrings.tomorrow;
    } else {
      return formatDate(date);
    }
  }

  static String getRelativeDateTime(DateTime date) {
    final now = DateTime.now();
    final targetDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (targetDate == today) {
      return '${AppStrings.today} ${formatTime(date)}';
    } else if (targetDate == today.subtract(const Duration(days: 1))) {
      return '${AppStrings.yesterday} ${formatTime(date)}';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return '${AppStrings.tomorrow} ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? AppStrings.day : AppStrings.days} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? AppStrings.hour : AppStrings.hours} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? AppStrings.minute : AppStrings.minutes} ago';
    } else {
      return 'Just now';
    }
  }

  static String getTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return AppStrings.overdue;
    }

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in $years ${years == 1 ? 'year' : 'years'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months ${months == 1 ? 'month' : 'months'}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? AppStrings.day : AppStrings.days}';
    } else if (difference.inHours > 0) {
      return '${AppStrings.dueIn} ${difference.inHours} ${difference.inHours == 1 ? AppStrings.hour : AppStrings.hours}';
    } else if (difference.inMinutes > 0) {
      return '${AppStrings.dueIn} ${difference.inMinutes} ${difference.inMinutes == 1 ? AppStrings.minute : AppStrings.minutes}';
    } else {
      return 'Due now';
    }
  }

  static String getDetailedTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return AppStrings.overdue;
    }

    if (difference.inDays > 0) {
      final hours = difference.inHours % 24;
      if (hours > 0) {
        return '${difference.inDays}d ${hours}h';
      } else {
        return '${difference.inDays}d';
      }
    } else if (difference.inHours > 0) {
      final minutes = difference.inMinutes % 60;
      if (minutes > 0) {
        return '${difference.inHours}h ${minutes}m';
      } else {
        return '${difference.inHours}h';
      }
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(
      date,
    ).add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static int hoursBetween(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  static int minutesBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDay = startOfMonth(date);
    final lastDay = endOfMonth(date);
    final days = <DateTime>[];

    for (
      var day = firstDay;
      day.isBefore(lastDay.add(const Duration(days: 1)));
      day = day.add(const Duration(days: 1))
    ) {
      days.add(day);
    }

    return days;
  }

  static List<DateTime> getDaysInWeek(DateTime date) {
    final startDay = startOfWeek(date);
    final days = <DateTime>[];

    for (int i = 0; i < 7; i++) {
      days.add(startDay.add(Duration(days: i)));
    }

    return days;
  }

  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var daysToAdd = days;

    while (daysToAdd > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday < 6) {
        // Monday = 1, Sunday = 7
        daysToAdd--;
      }
    }

    return result;
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static bool isBusinessDay(DateTime date) {
    return !isWeekend(date);
  }

  static DateTime nextBusinessDay(DateTime date) {
    var nextDay = date.add(const Duration(days: 1));
    while (isWeekend(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  static DateTime previousBusinessDay(DateTime date) {
    var prevDay = date.subtract(const Duration(days: 1));
    while (isWeekend(prevDay)) {
      prevDay = prevDay.subtract(const Duration(days: 1));
    }
    return prevDay;
  }

  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static DateTime parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static String timeStringFromDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static TimeOfDay timeOfDayFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static List<DateTime> getUpcomingDates(DateTime startDate, int count) {
    final dates = <DateTime>[];
    var currentDate = startDate;

    for (int i = 0; i < count; i++) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  static String getQuarter(DateTime date) {
    final quarter = ((date.month - 1) / 3).floor() + 1;
    return 'Q$quarter ${date.year}';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  static bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  static DateTime roundToNearestMinute(DateTime dateTime, int minutes) {
    final remainder = dateTime.minute % minutes;
    if (remainder == 0) return dateTime;

    final minutesToAdd = minutes - remainder;
    return dateTime.add(Duration(minutes: minutesToAdd));
  }

  static String getScheduleDisplay(DateTime dateTime) {
    if (isToday(dateTime)) {
      return '${AppStrings.today} at ${formatTimeAmPm(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return '${AppStrings.tomorrow} at ${formatTimeAmPm(dateTime)}';
    } else if (isThisWeek(dateTime)) {
      return '${formatWeekday(dateTime)} at ${formatTimeAmPm(dateTime)}';
    } else {
      return '${formatDate(dateTime)} at ${formatTimeAmPm(dateTime)}';
    }
  }

  // Additional utility methods for medication scheduling
  static List<DateTime> generateMedicationTimes(
    DateTime startDate,
    List<String> timeStrings,
    int days,
  ) {
    final times = <DateTime>[];

    for (int day = 0; day < days; day++) {
      final currentDate = startDate.add(Duration(days: day));

      for (final timeString in timeStrings) {
        final time = parseTimeString(timeString);
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          time.hour,
          time.minute,
        );
        times.add(scheduledTime);
      }
    }

    return times;
  }

  static bool isTimeWithinRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }

  static DateTime getNextOccurrence(List<String> timeStrings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final timeString in timeStrings) {
      final time = parseTimeString(timeString);
      final todayScheduledTime = DateTime(
        today.year,
        today.month,
        today.day,
        time.hour,
        time.minute,
      );

      if (todayScheduledTime.isAfter(now)) {
        return todayScheduledTime;
      }
    }

    // If no time today, return first time tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    final firstTime = parseTimeString(timeStrings.first);
    return DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      firstTime.hour,
      firstTime.minute,
    );
  }

  static List<DateTime> getMissedTimes(
    List<String> timeStrings,
    DateTime startDate,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final missed = <DateTime>[];

    // Check if startDate is today or before
    if (startDate.isBefore(today.add(const Duration(days: 1)))) {
      for (final timeString in timeStrings) {
        final time = parseTimeString(timeString);
        final scheduledTime = DateTime(
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );

        if (scheduledTime.isBefore(now) && scheduledTime.isAfter(startDate)) {
          missed.add(scheduledTime);
        }
      }
    }

    return missed;
  }

  static String getMedicationTimeStatus(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.isNegative) {
      return AppStrings.overdue;
    } else if (difference.inMinutes <= 15) {
      return 'Due soon';
    } else if (difference.inHours <= 1) {
      return 'Due in ${difference.inMinutes}m';
    } else {
      return 'Due in ${difference.inHours}h';
    }
  }

  static bool isWithinReminderWindow(
    DateTime scheduledTime,
    int reminderMinutes,
  ) {
    final now = DateTime.now();
    final reminderTime = scheduledTime.subtract(
      Duration(minutes: reminderMinutes),
    );
    return now.isAfter(reminderTime) && now.isBefore(scheduledTime);
  }

  // Health log specific utilities
  static String getHealthLogTimeDisplay(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return getTimeAgo(dateTime);
    } else if (isToday(dateTime)) {
      return '${AppStrings.today} at ${formatTimeAmPm(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return '${AppStrings.yesterday} at ${formatTimeAmPm(dateTime)}';
    } else if (isThisWeek(dateTime)) {
      return '${formatWeekdayShort(dateTime)} at ${formatTimeAmPm(dateTime)}';
    } else {
      return formatDateTime(dateTime);
    }
  }

  // Appointment specific utilities
  static String getAppointmentTimeDisplay(DateTime dateTime) {
    if (isToday(dateTime)) {
      return '${AppStrings.today} at ${formatTimeAmPm(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return '${AppStrings.tomorrow} at ${formatTimeAmPm(dateTime)}';
    } else if (isThisWeek(dateTime)) {
      return '${formatWeekday(dateTime)} at ${formatTimeAmPm(dateTime)}';
    } else {
      return '${formatDate(dateTime)} at ${formatTimeAmPm(dateTime)}';
    }
  }

  // Validation utilities
  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final hundredYearsAgo = now.subtract(const Duration(days: 36500));
    final hundredYearsFromNow = now.add(const Duration(days: 36500));

    return date.isAfter(hundredYearsAgo) && date.isBefore(hundredYearsFromNow);
  }

  static bool isValidTime(TimeOfDay time) {
    return time.hour >= 0 &&
        time.hour <= 23 &&
        time.minute >= 0 &&
        time.minute <= 59;
  }

  static bool isValidBirthDate(DateTime birthDate) {
    final now = DateTime.now();
    final age = getAge(birthDate);
    return age >= 0 && age <= 150;
  }

  // Sorting utilities
  static List<DateTime> sortDatesAscending(List<DateTime> dates) {
    final sortedDates = List<DateTime>.from(dates);
    sortedDates.sort((a, b) => a.compareTo(b));
    return sortedDates;
  }

  static List<DateTime> sortDatesDescending(List<DateTime> dates) {
    final sortedDates = List<DateTime>.from(dates);
    sortedDates.sort((a, b) => b.compareTo(a));
    return sortedDates;
  }

  // Timezone utilities
  static DateTime toLocalTime(DateTime utcTime) {
    return utcTime.toLocal();
  }

  static DateTime toUtcTime(DateTime localTime) {
    return localTime.toUtc();
  }

  // Custom formatting for specific use cases
  static String formatForApi(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  static DateTime parseFromApi(String apiDateString) {
    return DateTime.parse(apiDateString).toLocal();
  }

  static String formatForDisplay(DateTime dateTime) {
    return formatDateTime(dateTime);
  }

  static String formatForFileName(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd_HH-mm-ss').format(dateTime);
  }

  // Range utilities
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(microseconds: 1))) &&
        date.isBefore(end.add(const Duration(microseconds: 1)));
  }

  // Statistics utilities
  static double getAverageHourFromTimes(List<DateTime> times) {
    if (times.isEmpty) return 0;

    final totalHours = times.fold<double>(0, (sum, time) => sum + time.hour);
    return totalHours / times.length;
  }

  static DateTime getMostCommonTime(List<DateTime> times) {
    if (times.isEmpty) return DateTime.now();

    final timeMap = <String, int>{};
    for (final time in times) {
      final timeString = timeStringFromDateTime(time);
      timeMap[timeString] = (timeMap[timeString] ?? 0) + 1;
    }

    final mostCommon = timeMap.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return parseTimeString(mostCommon.key);
  }

  // Additional health app specific utilities
  static String getTimeBetweenDoses(DateTime lastDose, DateTime nextDose) {
    final difference = nextDose.difference(lastDose);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  static bool isTimeForReminder(
    DateTime scheduledTime,
    List<int> reminderMinutes,
  ) {
    final now = DateTime.now();

    for (final minutes in reminderMinutes) {
      final reminderTime = scheduledTime.subtract(Duration(minutes: minutes));
      if (now.isAfter(reminderTime.subtract(const Duration(minutes: 1))) &&
          now.isBefore(reminderTime.add(const Duration(minutes: 1)))) {
        return true;
      }
    }
    return false;
  }

  static List<DateTime> getUpcomingMedications(
    List<String> timeStrings,
    DateTime startDate,
    int daysAhead,
  ) {
    final upcoming = <DateTime>[];
    final now = DateTime.now();

    for (int day = 0; day < daysAhead; day++) {
      final currentDate = startDate.add(Duration(days: day));

      for (final timeString in timeStrings) {
        final time = parseTimeString(timeString);
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          time.hour,
          time.minute,
        );

        if (scheduledTime.isAfter(now)) {
          upcoming.add(scheduledTime);
        }
      }
    }

    return upcoming..sort((a, b) => a.compareTo(b));
  }

  static String getAdherenceStatus(
    List<DateTime> scheduledTimes,
    List<DateTime> takenTimes,
  ) {
    if (scheduledTimes.isEmpty) return 'No data';

    final adherenceRate = (takenTimes.length / scheduledTimes.length * 100)
        .round();

    if (adherenceRate >= 95) {
      return 'Excellent ($adherenceRate%)';
    } else if (adherenceRate >= 80) {
      return 'Good ($adherenceRate%)';
    } else if (adherenceRate >= 60) {
      return 'Fair ($adherenceRate%)';
    } else {
      return 'Poor ($adherenceRate%)';
    }
  }

  static List<DateTime> getWeeklyMedicationTimes(
    DateTime startOfWeek,
    List<String> dailyTimes,
  ) {
    final weeklyTimes = <DateTime>[];

    for (int day = 0; day < 7; day++) {
      final currentDate = startOfWeek.add(Duration(days: day));

      for (final timeString in dailyTimes) {
        final time = parseTimeString(timeString);
        final scheduledTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          time.hour,
          time.minute,
        );
        weeklyTimes.add(scheduledTime);
      }
    }

    return weeklyTimes;
  }

  static String getHealthMetricTrend(List<double> values) {
    if (values.length < 2) return 'Insufficient data';

    final recentCount = values.length >= 3 ? 3 : values.length;
    final recent =
        values
            .skip(values.length - recentCount)
            .fold<double>(0, (sum, val) => sum + val) /
        recentCount;
    final previousCount = values.length - recentCount;

    if (previousCount <= 0) return 'Insufficient data';

    final previous =
        values.take(previousCount).fold<double>(0, (sum, val) => sum + val) /
        previousCount;

    final change = ((recent - previous) / previous * 100).round();

    if (change.abs() < 5) {
      return 'Stable';
    } else if (change > 0) {
      return 'Increasing ($change%)';
    } else {
      return 'Decreasing (${change.abs()}%)';
    }
  }

  static DateTime getOptimalMedicationTime(List<DateTime> historicalTimes) {
    if (historicalTimes.isEmpty) return DateTime.now();

    final hourCounts = <int, int>{};
    for (final time in historicalTimes) {
      hourCounts[time.hour] = (hourCounts[time.hour] ?? 0) + 1;
    }

    final optimalHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day, optimalHour, 0);
  }

  static bool isInMedicationWindow(DateTime scheduledTime, int windowMinutes) {
    final now = DateTime.now();
    final windowStart = scheduledTime.subtract(
      Duration(minutes: windowMinutes),
    );
    final windowEnd = scheduledTime.add(Duration(minutes: windowMinutes));

    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }

  static String formatTimeRemaining(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
