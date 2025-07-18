// lib/widgets/appointments/appointment_reminder.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';

class AppointmentReminder extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onDismiss;
  final VoidCallback? onViewDetails;
  final VoidCallback? onReschedule;
  final VoidCallback? onMarkComplete;
  final bool showActions;
  final String? customMessage;

  const AppointmentReminder({
    Key? key,
    required this.appointment,
    this.onDismiss,
    this.onViewDetails,
    this.onReschedule,
    this.onMarkComplete,
    this.showActions = true,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildAppointmentInfo(),
          const SizedBox(height: 12),
          _buildTimeInfo(),
          if (showActions) ...[
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notifications_active,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customMessage ?? 'Appointment Reminder',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _getTimeUntilAppointment(),
                style: TextStyle(
                  fontSize: 12,
                  color: _getUrgencyColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onDismiss != null)
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildAppointmentInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Dr. ${appointment.doctorName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (appointment.specialty.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        appointment.specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor().withOpacity(0.5)),
          ),
          child: Text(
            appointment.type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeDetail(
              'Date',
              DateFormat('EEE, MMM dd').format(appointment.dateTime),
              Icons.calendar_today,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.primaryColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildTimeDetail(
              'Time',
              DateFormat('h:mm a').format(appointment.dateTime),
              Icons.access_time,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.primaryColor.withOpacity(0.3),
          ),
          Expanded(
            child: _buildTimeDetail(
              'Location',
              appointment.location.isNotEmpty ? appointment.location : 'TBD',
              Icons.location_on,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onViewDetails != null)
          Expanded(
            child: _buildActionButton(
              'View Details',
              Icons.info_outline,
              AppColors.primaryColor,
              onViewDetails!,
            ),
          ),
        if (onViewDetails != null &&
            (onReschedule != null || onMarkComplete != null))
          const SizedBox(width: 8),
        if (onReschedule != null)
          Expanded(
            child: _buildActionButton(
              'Reschedule',
              Icons.schedule,
              Colors.orange,
              onReschedule!,
            ),
          ),
        if (onReschedule != null && onMarkComplete != null)
          const SizedBox(width: 8),
        if (onMarkComplete != null && _canMarkComplete())
          Expanded(
            child: _buildActionButton(
              'Complete',
              Icons.check_circle_outline,
              Colors.green,
              onMarkComplete!,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withOpacity(0.1),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }

  String _getTimeUntilAppointment() {
    final now = DateTime.now();
    final difference = appointment.dateTime.difference(now);

    if (difference.isNegative) {
      final pastDifference = now.difference(appointment.dateTime);
      if (pastDifference.inMinutes < 60) {
        return 'Started ${pastDifference.inMinutes} minutes ago';
      } else if (pastDifference.inHours < 24) {
        return 'Started ${pastDifference.inHours} hours ago';
      } else {
        return 'Was ${pastDifference.inDays} days ago';
      }
    }

    if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inDays < 7) {
      return 'In ${difference.inDays} days';
    } else {
      return 'In ${(difference.inDays / 7).floor()} weeks';
    }
  }

  Color _getUrgencyColor() {
    final now = DateTime.now();
    final difference = appointment.dateTime.difference(now);

    if (difference.isNegative) {
      return Colors.red;
    } else if (difference.inMinutes <= 15) {
      return Colors.red;
    } else if (difference.inMinutes <= 60) {
      return Colors.orange;
    } else if (difference.inHours <= 24) {
      return AppColors.primaryColor;
    } else {
      return AppColors.textSecondary;
    }
  }

  Color _getStatusColor() {
    switch (appointment.type) {
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
        return Colors.teal;
      case AppointmentType.vaccination:
        return Colors.orange;
      case AppointmentType.therapy:
        return Colors.purple;
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

  bool _canMarkComplete() {
    final now = DateTime.now();
    return appointment.status == AppointmentStatus.scheduled &&
        now.isAfter(appointment.dateTime.subtract(const Duration(minutes: 15)));
  }
}

// Reminder notification banner widget for the top of screens
class ReminderBanner extends StatelessWidget {
  final List<AppointmentModel> upcomingAppointments;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ReminderBanner({
    Key? key,
    required this.upcomingAppointments,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (upcomingAppointments.isEmpty) return const SizedBox.shrink();

    final nextAppointment = upcomingAppointments.first;
    final timeUntil = nextAppointment.dateTime.difference(DateTime.now());

    // Only show banner for appointments within the next 2 hours
    if (timeUntil.inHours > 2) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming Appointment',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${nextAppointment.title} • ${_formatTimeUntil(timeUntil)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
                if (onDismiss != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDismiss,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inMinutes < 60) {
      return 'in ${duration.inMinutes}m';
    } else {
      return 'in ${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}
