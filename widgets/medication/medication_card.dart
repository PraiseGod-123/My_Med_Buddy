// lib/widgets/medication/medication_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medication_model.dart';

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String medicationId, DateTime scheduledTime, bool isTaken)?
  onDoseAction;
  final bool showActions;
  final bool isCompact;
  final bool showNextDose;

  const MedicationCard({
    Key? key,
    required this.medication,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDoseAction,
    this.showActions = true,
    this.isCompact = false,
    this.showNextDose = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getMedicationColor().withOpacity(0.2),
            width: 1,
          ),
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
            if (!isCompact) ...[
              const SizedBox(height: 12),
              _buildMedicationInfo(),
              const SizedBox(height: 12),
              _buildScheduleInfo(),
              if (showActions) ...[
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getMedicationColor(),
                _getMedicationColor().withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.medication, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                medication.dosage,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: medication.isActive
                    ? Colors.green.withOpacity(0.1)
                    : AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: medication.isActive
                      ? Colors.green.withOpacity(0.3)
                      : AppColors.errorColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                medication.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: medication.isActive
                      ? Colors.green
                      : AppColors.errorColor,
                ),
              ),
            ),
            if (!isCompact && showNextDose) ...[
              const SizedBox(height: 4),
              _buildNextDoseIndicator(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoItem(
            Icons.schedule,
            'Frequency',
            medication.frequency,
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            Icons.access_time,
            'Times',
            '${medication.times.length} daily',
          ),
        ),
        Expanded(
          child: _buildInfoItem(
            Icons.calendar_today,
            'Since',
            DateFormat('MMM dd').format(medication.startDate),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: _getMedicationColor()),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScheduleInfo() {
    final nextDose = _getNextDoseTime();
    final missedToday = _getMissedDosesToday();
    final adherenceRate = _calculateAdherenceRate();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getMedicationColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (nextDose != null)
            Row(
              children: [
                Icon(Icons.alarm, size: 16, color: _getMedicationColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next dose: ${DateFormat('h:mm a').format(nextDose)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getMedicationColor(),
                    ),
                  ),
                ),
                if (_isOverdue(nextDose))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorColor,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Adherence',
                  '${adherenceRate.toInt()}%',
                  adherenceRate,
                ),
              ),
              if (missedToday > 0)
                Expanded(
                  child: _buildMiniStat('Missed Today', '$missedToday', 0.0),
                ),
              Expanded(
                child: _buildMiniStat('Streak', '${_getStreak()} days', 100.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, double score) {
    final color = score >= 80
        ? Colors.green
        : score >= 60
        ? Colors.orange
        : AppColors.errorColor;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextDoseIndicator() {
    final nextDose = _getNextDoseTime();
    if (nextDose == null) return const SizedBox.shrink();

    final timeUntil = nextDose.difference(DateTime.now());
    final isOverdue = timeUntil.isNegative;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppColors.errorColor.withOpacity(0.1)
            : _getMedicationColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOverdue ? 'OVERDUE' : _formatTimeUntil(timeUntil),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: isOverdue ? AppColors.errorColor : _getMedicationColor(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final nextDose = _getNextDoseTime();
    final canTakeNow =
        nextDose != null &&
        (nextDose.isBefore(DateTime.now()) ||
            nextDose.difference(DateTime.now()).inMinutes <= 15);

    return Row(
      children: [
        if (canTakeNow && onDoseAction != null) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onDoseAction!(medication.id, nextDose!, true),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Take Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onEdit != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _getMedicationColor(),
                side: BorderSide(color: _getMedicationColor().withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 8),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: AppColors.errorColor),
            tooltip: 'Delete medication',
          ),
      ],
    );
  }

  DateTime? _getNextDoseTime() {
    final now = DateTime.now();

    for (final timeStr in medication.times) {
      final time = _parseTimeString(timeStr);
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Check if there's already a log for this time
      final hasLog = medication.logs.any(
        (log) =>
            log.scheduledTime.year == scheduledDateTime.year &&
            log.scheduledTime.month == scheduledDateTime.month &&
            log.scheduledTime.day == scheduledDateTime.day &&
            log.scheduledTime.hour == scheduledDateTime.hour &&
            log.scheduledTime.minute == scheduledDateTime.minute,
      );

      if (!hasLog &&
          (scheduledDateTime.isAfter(now) ||
              now.difference(scheduledDateTime).inHours < 1)) {
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

  int _getMissedDosesToday() {
    final now = DateTime.now();
    int missed = 0;

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
        final hasLog = medication.logs.any(
          (log) =>
              log.scheduledTime.year == scheduledDateTime.year &&
              log.scheduledTime.month == scheduledDateTime.month &&
              log.scheduledTime.day == scheduledDateTime.day &&
              log.scheduledTime.hour == scheduledDateTime.hour &&
              log.scheduledTime.minute == scheduledDateTime.minute &&
              (log.isTaken || log.isSkipped),
        );

        if (!hasLog) missed++;
      }
    }

    return missed;
  }

  double _calculateAdherenceRate() {
    if (medication.logs.isEmpty) return 100.0;

    final takenLogs = medication.logs.where((log) => log.isTaken).length;
    return (takenLogs / medication.logs.length) * 100;
  }

  int _getStreak() {
    // Calculate consecutive days with all doses taken
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 30; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final dayLogs = medication.logs
          .where(
            (log) =>
                log.scheduledTime.year == checkDate.year &&
                log.scheduledTime.month == checkDate.month &&
                log.scheduledTime.day == checkDate.day,
          )
          .toList();

      if (dayLogs.isEmpty) continue;

      final expectedDoses = medication.times.length;
      final takenDoses = dayLogs.where((log) => log.isTaken).length;

      if (takenDoses == expectedDoses) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  bool _isOverdue(DateTime scheduledTime) {
    return scheduledTime.isBefore(DateTime.now());
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
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
}
