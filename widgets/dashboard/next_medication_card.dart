// lib/widgets/dashboard/weekly_appointments_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointments_provider.dart';

class WeeklyAppointmentsCard extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onViewAll;

  const WeeklyAppointmentsCard({Key? key, this.onTap, this.onViewAll})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, provider, child) {
        final weeklyAppointments = _getThisWeekAppointments(provider);
        final todaysAppointments = provider.todaysAppointments;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
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
                _buildHeader(
                  weeklyAppointments.length,
                  todaysAppointments.length,
                ),
                const SizedBox(height: 16),
                if (weeklyAppointments.isEmpty)
                  _buildNoAppointments()
                else
                  _buildAppointmentsList(weeklyAppointments),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(int weeklyCount, int todayCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                todayCount > 0
                    ? '$todayCount today • $weeklyCount total'
                    : '$weeklyCount appointments',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoAppointments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 40,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Appointments This Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Schedule your next appointment to stay on top of your health',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Schedule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    // Group appointments by day
    final groupedAppointments = _groupAppointmentsByDay(appointments);
    final sortedDays = groupedAppointments.keys.toList()..sort();

    return Column(
      children: [
        // Show today's appointments prominently if any
        if (groupedAppointments.containsKey(_getDateKey(DateTime.now())))
          _buildTodaySection(groupedAppointments[_getDateKey(DateTime.now())]!),

        // Show upcoming days
        ...sortedDays
            .where((day) => day != _getDateKey(DateTime.now()))
            .take(3)
            .map((day) {
              return _buildDaySection(day, groupedAppointments[day]!);
            }),

        if (appointments.length > 3) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${appointments.length - 3} more this week',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodaySection(List<AppointmentModel> todaysAppointments) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...todaysAppointments.map((appointment) {
            return _buildAppointmentItem(appointment, isToday: true);
          }),
        ],
      ),
    );
  }

  Widget _buildDaySection(String dayKey, List<AppointmentModel> appointments) {
    final date = DateTime.parse(dayKey);
    final isToday = _getDateKey(DateTime.now()) == dayKey;
    final isTomorrow =
        _getDateKey(DateTime.now().add(const Duration(days: 1))) == dayKey;

    String dayLabel;
    if (isToday) {
      dayLabel = 'Today';
    } else if (isTomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = DateFormat('EEEE').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  dayLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d').format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${appointments.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...appointments.take(2).map((appointment) {
            return _buildAppointmentItem(appointment);
          }),
          if (appointments.length > 2)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                '+${appointments.length - 2} more',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(
    AppointmentModel appointment, {
    bool isToday = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isToday
            ? Colors.white.withOpacity(0.7)
            : AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: _getAppointmentTypeColor(appointment.type),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Dr. ${appointment.doctorName}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(appointment.dateTime),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status.displayName,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(appointment.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<AppointmentModel> _getThisWeekAppointments(
    AppointmentsProvider provider,
  ) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return provider.appointments.where((appointment) {
      return appointment.dateTime.isAfter(
            startOfWeek.subtract(const Duration(days: 1)),
          ) &&
          appointment.dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Map<String, List<AppointmentModel>> _groupAppointmentsByDay(
    List<AppointmentModel> appointments,
  ) {
    final Map<String, List<AppointmentModel>> grouped = {};

    for (final appointment in appointments) {
      final dayKey = _getDateKey(appointment.dateTime);
      if (!grouped.containsKey(dayKey)) {
        grouped[dayKey] = [];
      }
      grouped[dayKey]!.add(appointment);
    }

    // Sort appointments within each day
    for (final appointments in grouped.values) {
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getAppointmentTypeColor(AppointmentType type) {
    switch (type) {
      case AppointmentType.checkup:
        return AppColors.primaryColor;
      case AppointmentType.consultation:
        return Colors.green;
      case AppointmentType.followUp:
        return Colors.blue;
      case AppointmentType.emergency:
        return Colors.red;
      case AppointmentType.surgery:
        return Colors.red;
      case AppointmentType.diagnostic:
        return Colors.orange;
      case AppointmentType.vaccination:
        return Colors.purple;
      case AppointmentType.therapy:
        return Colors.teal;
      case AppointmentType.dentistry:
        return Colors.indigo;
      case AppointmentType.vision:
        return Colors.amber;
      case AppointmentType.specialist:
        return Colors.deepPurple;
      case AppointmentType.other:
        return Colors.grey;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.primaryColor;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rescheduled:
        return Colors.orange;
      case AppointmentStatus.missed:
        return Colors.grey;
      case AppointmentStatus.waitingList:
        return Colors.grey;
    }
  }
}
