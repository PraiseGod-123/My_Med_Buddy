// lib/widgets/medication/dose_tracker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medication_model.dart';

class DoseTracker extends StatelessWidget {
  final MedicationModel medication;
  final DateTime? selectedDate;
  final Function(MedicationLog)? onLogTap;
  final Function(String medicationId, DateTime scheduledTime, bool isTaken)?
  onDoseAction;
  final bool showWeekView;

  const DoseTracker({
    Key? key,
    required this.medication,
    this.selectedDate,
    this.onLogTap,
    this.onDoseAction,
    this.showWeekView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (showWeekView) _buildWeekView() else _buildDayView(),
          const SizedBox(height: 16),
          _buildAdherenceStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final adherenceRate = _calculateAdherenceRate();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getMedicationColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.medication, color: _getMedicationColor(), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${medication.dosage} • ${medication.frequency}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getAdherenceColor(adherenceRate).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${adherenceRate.toInt()}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getAdherenceColor(adherenceRate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayView() {
    final date = selectedDate ?? DateTime.now();
    final daySchedule = _getDaySchedule(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(date),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (daySchedule.isEmpty)
          _buildEmptyDay(date)
        else
          Column(
            children: daySchedule.map((schedule) {
              return _buildDoseItem(schedule);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _getStartOfWeek(selectedDate ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Week',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildWeekGrid(startOfWeek),
      ],
    );
  }

  Widget _buildWeekGrid(DateTime startOfWeek) {
    return Column(
      children: List.generate(7, (dayIndex) {
        final date = startOfWeek.add(Duration(days: dayIndex));
        final daySchedule = _getDaySchedule(date);
        final isToday = _isSameDay(date, DateTime.now());

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primaryColor.withOpacity(0.1)
                : AppColors.lightColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.primaryColor.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? AppColors.primaryColor
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? AppColors.primaryColor
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: medication.times.map((timeStr) {
                    final time = _parseTimeString(timeStr);
                    final scheduledDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                    final log = _getLogForTime(scheduledDateTime);

                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: _buildDoseCircle(log, scheduledDateTime),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDoseItem(DoseScheduleItem schedule) {
    final log = schedule.log;
    final isOverdue = schedule.isOverdue;
    final canTakeAction = schedule.canTakeAction;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getDoseItemColor(log, isOverdue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getDoseItemColor(log, isOverdue).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          _buildDoseCircle(log, schedule.scheduledTime),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(schedule.scheduledTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getDoseStatusText(log, isOverdue),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDoseItemColor(log, isOverdue),
                  ),
                ),
              ],
            ),
          ),
          if (canTakeAction && log == null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(
                  Icons.check,
                  Colors.green,
                  'Take',
                  () => _handleDoseAction(schedule.scheduledTime, true),
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  Icons.close,
                  AppColors.errorColor,
                  'Skip',
                  () => _handleDoseAction(schedule.scheduledTime, false),
                ),
              ],
            ),
          if (log != null && onLogTap != null)
            IconButton(
              onPressed: () => onLogTap!(log),
              icon: const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              tooltip: 'View details',
            ),
        ],
      ),
    );
  }

  Widget _buildDoseCircle(MedicationLog? log, DateTime scheduledTime) {
    final isOverdue = scheduledTime.isBefore(DateTime.now()) && log == null;
    final color = _getDoseItemColor(log, isOverdue);
    final icon = _getDoseIcon(log, isOverdue);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: log != null ? color : color.withOpacity(0.2),
        border: Border.all(color: color, width: log != null ? 0 : 2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: log != null ? Colors.white : color),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildEmptyDay(DateTime date) {
    final isPast = date.isBefore(DateTime.now());
    final isFuture = date.isAfter(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            isPast ? Icons.history : Icons.schedule,
            size: 32,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            isPast
                ? 'No doses were scheduled'
                : isFuture
                ? 'No doses scheduled yet'
                : 'No doses today',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceStats() {
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('Taken', stats.taken, Colors.green)),
          Expanded(
            child: _buildStatItem('Missed', stats.missed, AppColors.errorColor),
          ),
          Expanded(
            child: _buildStatItem(
              'Streak',
              stats.streak,
              AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  List<DoseScheduleItem> _getDaySchedule(DateTime date) {
    final List<DoseScheduleItem> schedule = [];
    final now = DateTime.now();

    for (final timeStr in medication.times) {
      final time = _parseTimeString(timeStr);
      final scheduledDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final log = _getLogForTime(scheduledDateTime);
      final isOverdue = scheduledDateTime.isBefore(now) && log == null;
      final canTakeAction =
          _isSameDay(date, now) &&
          (scheduledDateTime.isBefore(now) ||
              scheduledDateTime.difference(now).inMinutes <= 15);

      schedule.add(
        DoseScheduleItem(
          scheduledTime: scheduledDateTime,
          log: log,
          isOverdue: isOverdue,
          canTakeAction: canTakeAction,
        ),
      );
    }

    schedule.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return schedule;
  }

  MedicationLog? _getLogForTime(DateTime scheduledTime) {
    return medication.logs.where((log) {
      return log.scheduledTime.year == scheduledTime.year &&
          log.scheduledTime.month == scheduledTime.month &&
          log.scheduledTime.day == scheduledTime.day &&
          log.scheduledTime.hour == scheduledTime.hour &&
          log.scheduledTime.minute == scheduledTime.minute;
    }).firstOrNull;
  }

  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (_isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  double _calculateAdherenceRate() {
    if (medication.logs.isEmpty) return 100.0;

    final takenLogs = medication.logs.where((log) => log.isTaken).length;
    return (takenLogs / medication.logs.length) * 100;
  }

  AdherenceStats _calculateStats() {
    final logs = medication.logs;
    final taken = logs.where((log) => log.isTaken).length;
    final missed = logs.where((log) => log.isSkipped).length;

    // Calculate streak (consecutive days with all doses taken)
    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dayLogs = logs
          .where((log) => _isSameDay(log.scheduledTime, checkDate))
          .toList();

      if (dayLogs.isEmpty) continue;

      final allTaken = dayLogs.every((log) => log.isTaken);
      if (allTaken) {
        streak++;
      } else {
        break;
      }
    }

    return AdherenceStats(taken: taken, missed: missed, streak: streak);
  }

  Color _getMedicationColor() {
    switch (medication.color) {
      case 'primary':
        return AppColors.primaryColor;
      case 'secondary':
        return AppColors.secondaryColor;
      case 'accent':
        return AppColors.accentColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return AppColors.errorColor;
  }

  Color _getDoseItemColor(MedicationLog? log, bool isOverdue) {
    if (log != null) {
      return log.isTaken ? Colors.green : AppColors.errorColor;
    }
    return isOverdue ? AppColors.errorColor : AppColors.textSecondary;
  }

  IconData _getDoseIcon(MedicationLog? log, bool isOverdue) {
    if (log != null) {
      return log.isTaken ? Icons.check : Icons.close;
    }
    return isOverdue ? Icons.warning : Icons.schedule;
  }

  String _getDoseStatusText(MedicationLog? log, bool isOverdue) {
    if (log != null) {
      return log.isTaken ? 'Taken' : 'Skipped';
    }
    return isOverdue ? 'Overdue' : 'Scheduled';
  }

  void _handleDoseAction(DateTime scheduledTime, bool isTaken) {
    onDoseAction?.call(medication.id, scheduledTime, isTaken);
  }
}

class DoseScheduleItem {
  final DateTime scheduledTime;
  final MedicationLog? log;
  final bool isOverdue;
  final bool canTakeAction;

  DoseScheduleItem({
    required this.scheduledTime,
    this.log,
    required this.isOverdue,
    required this.canTakeAction,
  });
}

class AdherenceStats {
  final int taken;
  final int missed;
  final int streak;

  AdherenceStats({
    required this.taken,
    required this.missed,
    required this.streak,
  });
}
