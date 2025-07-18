// lib/widgets/appointments/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onComplete;
  final bool showActions;
  final bool isCompact;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCancel,
    this.onReschedule,
    this.onComplete,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _getStatusColor().withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, _getStatusColor().withOpacity(0.02)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildContent(),
              if (!isCompact) ...[const SizedBox(height: 12), _buildDetails()],
              if (showActions && !isCompact) ...[
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getTypeIcon(), color: _getStatusColor(), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Dr. ${appointment.doctorName}',
                style: const TextStyle(
                  fontSize: 14,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (appointment.isReminderSet)
              Icon(
                Icons.notifications_active,
                size: 14,
                color: AppColors.primaryColor.withOpacity(0.7),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTimeInfo()),
          if (!isCompact) ...[
            Container(
              width: 1,
              height: 40,
              color: AppColors.primaryColor.withOpacity(0.2),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildLocationInfo()),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: AppColors.primaryColor),
            const SizedBox(width: 6),
            Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(appointment.dateTime),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          DateFormat('h:mm a').format(appointment.dateTime),
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: AppColors.primaryColor),
            const SizedBox(width: 6),
            Text(
              'Location',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          appointment.location.isNotEmpty ? appointment.location : 'TBD',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        if (appointment.specialty.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment.specialty,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                _formatDuration(appointment.duration),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (appointment.isReminderSet)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications,
                  size: 12,
                  color: AppColors.accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${appointment.reminderMinutes}m',
                  style: TextStyle(fontSize: 12, color: AppColors.accentColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final actions = _getAvailableActions();
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < actions.length - 1 ? 8 : 0),
            child: _buildActionButton(action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(AppointmentAction action) {
    return ElevatedButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 16),
      label: Text(
        action.label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: action.isPrimary ? Colors.white : action.color,
        backgroundColor: action.isPrimary
            ? action.color
            : action.color.withOpacity(0.1),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: action.isPrimary
              ? BorderSide.none
              : BorderSide(color: action.color.withOpacity(0.3)),
        ),
      ),
    );
  }

  List<AppointmentAction> _getAvailableActions() {
    final List<AppointmentAction> actions = [];
    final now = DateTime.now();

    // Primary actions based on appointment status and time
    if (appointment.isUpcoming) {
      if (appointment.canReschedule && onReschedule != null) {
        actions.add(
          AppointmentAction(
            label: 'Reschedule',
            icon: Icons.schedule,
            color: AppColors.primaryColor,
            onPressed: onReschedule!,
            isPrimary: true,
          ),
        );
      }

      if (appointment.canCancel && onCancel != null) {
        actions.add(
          AppointmentAction(
            label: 'Cancel',
            icon: Icons.cancel,
            color: Colors.red,
            onPressed: onCancel!,
          ),
        );
      }
    } else if (appointment.isPast &&
        appointment.status == AppointmentStatus.scheduled &&
        onComplete != null) {
      actions.add(
        AppointmentAction(
          label: 'Mark Complete',
          icon: Icons.check_circle,
          color: Colors.green,
          onPressed: onComplete!,
          isPrimary: true,
        ),
      );
    }

    // Secondary actions
    if (onEdit != null) {
      actions.add(
        AppointmentAction(
          label: 'Edit',
          icon: Icons.edit,
          color: AppColors.textSecondary,
          onPressed: onEdit!,
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        AppointmentAction(
          label: 'Delete',
          icon: Icons.delete,
          color: Colors.red,
          onPressed: onDelete!,
        ),
      );
    }

    return actions;
  }

  IconData _getTypeIcon() {
    switch (appointment.type) {
      case AppointmentType.checkup:
        return Icons.health_and_safety;
      case AppointmentType.consultation:
        return Icons.chat;
      case AppointmentType.followUp:
        return Icons.follow_the_signs;
      case AppointmentType.emergency:
        return Icons.emergency;
      case AppointmentType.surgery:
        return Icons.medical_services;
      case AppointmentType.diagnostic:
        return Icons.search;
      case AppointmentType.vaccination:
        return Icons.vaccines;
      case AppointmentType.therapy:
        return Icons.psychology;
      case AppointmentType.dentistry:
        return Icons.medical_services;
      case AppointmentType.vision:
        return Icons.visibility;
      case AppointmentType.specialist:
        return Icons.medical_information;
      case AppointmentType.other:
        return Icons.more_horiz;
    }
  }

  Color _getStatusColor() {
    switch (appointment.status) {
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

  String _getStatusText() {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.missed:
        return 'Missed';
      case AppointmentStatus.waitingList:
        return 'Waiting List';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

class AppointmentAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  AppointmentAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });
}
