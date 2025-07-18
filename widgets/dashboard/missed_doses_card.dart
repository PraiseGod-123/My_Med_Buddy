// lib/widgets/dashboard/missed_doses_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';

class MissedDosesCard extends StatelessWidget {
  final VoidCallback? onTap;

  const MissedDosesCard({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final missedCount = provider.missedDosesToday;
        final missedMedications = _getMissedMedications(provider);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: missedCount > 0
                    ? AppColors.errorColor.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
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
                _buildHeader(missedCount),
                const SizedBox(height: 16),
                if (missedCount == 0)
                  _buildNoMissedDoses()
                else
                  _buildMissedDosesList(missedMedications, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int missedCount) {
    final color = missedCount > 0 ? AppColors.errorColor : Colors.green;
    final icon = missedCount > 0 ? Icons.warning : Icons.check_circle;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Missed Doses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                missedCount == 0
                    ? 'All caught up today!'
                    : '$missedCount missed today',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            '$missedCount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoMissedDoses() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sentiment_very_satisfied,
                size: 32,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              const Text(
                'Perfect Adherence!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'You haven\'t missed any doses today. Keep up the great work!',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildAdherenceStreak(),
      ],
    );
  }

  Widget _buildAdherenceStreak() {
    // This would typically come from the provider, but for demo purposes
    final streakDays = 7; // Mock data

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays day streak!',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissedDosesList(
    List<MissedDoseInfo> missedMedications,
    MedicationProvider provider,
  ) {
    return Column(
      children: [
        ...missedMedications.take(3).map((missed) {
          return _buildMissedDoseItem(missed, provider);
        }),
        if (missedMedications.length > 3) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${missedMedications.length - 3} more missed doses',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildQuickActions(missedMedications, provider),
      ],
    );
  }

  Widget _buildMissedDoseItem(
    MissedDoseInfo missed,
    MedicationProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getMedicationColor(missed.medication.color),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  missed.medication.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${missed.medication.dosage} • ${DateFormat('h:mm a').format(missed.scheduledTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                _getTimeSinceMissed(missed.scheduledTime),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ),
              const Text(
                'overdue',
                style: TextStyle(fontSize: 10, color: AppColors.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    List<MissedDoseInfo> missedMedications,
    MedicationProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: missedMedications.isNotEmpty
                ? () => _markAllAsTaken(missedMedications, provider)
                : null,
            icon: const Icon(Icons.check_circle, size: 16),
            label: const Text('Take All'),
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
        Expanded(
          child: OutlinedButton.icon(
            onPressed: missedMedications.isNotEmpty
                ? () => _markAllAsSkipped(missedMedications, provider)
                : null,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Skip All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorColor,
              side: BorderSide(color: AppColors.errorColor.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  List<MissedDoseInfo> _getMissedMedications(MedicationProvider provider) {
    final now = DateTime.now();
    final List<MissedDoseInfo> missed = [];

    for (final medication in provider.todaysMedications) {
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

          if (!logExists) {
            missed.add(
              MissedDoseInfo(
                medication: medication,
                scheduledTime: scheduledDateTime,
              ),
            );
          }
        }
      }
    }

    // Sort by scheduled time (most recent first)
    missed.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    return missed;
  }

  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _getTimeSinceMissed(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = now.difference(scheduledTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Color _getMedicationColor(String colorKey) {
    switch (colorKey) {
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

  void _markAllAsTaken(
    List<MissedDoseInfo> missedMedications,
    MedicationProvider provider,
  ) {
    for (final missed in missedMedications) {
      provider.logMedication(
        medicationId: missed.medication.id,
        scheduledTime: missed.scheduledTime,
        takenTime: DateTime.now(),
        isTaken: true,
        notes: 'Marked as taken (late)',
      );
    }
  }

  void _markAllAsSkipped(
    List<MissedDoseInfo> missedMedications,
    MedicationProvider provider,
  ) {
    for (final missed in missedMedications) {
      provider.logMedication(
        medicationId: missed.medication.id,
        scheduledTime: missed.scheduledTime,
        isTaken: false,
        isSkipped: true,
        notes: 'Skipped by user',
      );
    }
  }
}

class MissedDoseInfo {
  final MedicationModel medication;
  final DateTime scheduledTime;

  MissedDoseInfo({required this.medication, required this.scheduledTime});
}
