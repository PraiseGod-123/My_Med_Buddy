// lib/screens/home/dashboard_widgets.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/health_log_model.dart';
import '../../models/medication_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/medication_provider.dart';
import '../../providers/health_logs_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../services/shared_prefs_service.dart';
import '../../widgets/common/custom_button.dart';
import '../medication/medication_schedule_screnn.dart';
import '../health_logs/health_logs_screen.dart';
import '../../screens/appointments/apointments_screen.dart';

class DashboardWidgets {
  // Welcome Header Widget
  static Widget buildWelcomeHeader(BuildContext context, UserModel? user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                user?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'How are you feeling today?',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              _showNotificationsDialog(context);
            },
          ),
        ),
      ],
    );
  }

  // Quick Stats Widget
  static Widget buildQuickStats(BuildContext context) {
    return Consumer3<
      MedicationProvider,
      HealthLogsProvider,
      AppointmentsProvider
    >(
      builder:
          (
            context,
            medicationProvider,
            healthLogsProvider,
            appointmentsProvider,
            child,
          ) {
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Medications',
                    '${medicationProvider.activeMedications.length}',
                    Icons.medication,
                    AppColors.primaryColor,
                    () => _navigateToMedications(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Appointments',
                    '${appointmentsProvider.upcomingAppointments.length}',
                    Icons.calendar_today,
                    AppColors.secondaryColor,
                    () => _navigateToAppointments(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Health Logs',
                    '${healthLogsProvider.healthLogs.length}',
                    Icons.analytics,
                    AppColors.accentColor,
                    () => _navigateToHealthLogs(context),
                  ),
                ),
              ],
            );
          },
    );
  }

  // Next Medication Card Widget
  static Widget buildNextMedicationCard(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        final nextMedication = medicationProvider.nextMedication;

        if (nextMedication == null) {
          return _buildEmptyCard(
            context,
            'No Medications Due',
            'All your medications are up to date!',
            Icons.medication,
            AppColors.primaryColor,
            () => _navigateToMedications(context),
          );
        }

        // Calculate next dose time
        final now = DateTime.now();
        DateTime? nextDoseTime;

        for (final timeStr in nextMedication.times) {
          final time = _parseTimeString(timeStr);
          final scheduledDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );

          if (scheduledDateTime.isAfter(now)) {
            if (nextDoseTime == null ||
                scheduledDateTime.isBefore(nextDoseTime)) {
              nextDoseTime = scheduledDateTime;
            }
          }
        }

        final isOverdue = nextDoseTime != null && nextDoseTime.isBefore(now);
        final formattedTime = nextDoseTime != null
            ? '${nextDoseTime.hour.toString().padLeft(2, '0')}:${nextDoseTime.minute.toString().padLeft(2, '0')}'
            : 'No time set';

        return Container(
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medication,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Next Medication',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToMedications(context),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getMedicationColor(nextMedication.color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nextMedication.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextMedication.dosage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? AppColors.errorColor.withOpacity(0.1)
                                : AppColors.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOverdue ? 'Overdue' : 'Due Soon',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue
                                  ? AppColors.errorColor
                                  : AppColors.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Recent Health Logs Card Widget
  static Widget buildRecentHealthLogsCard(BuildContext context) {
    return Consumer<HealthLogsProvider>(
      builder: (context, healthLogsProvider, child) {
        final recentLogs = healthLogsProvider.recentLogs;

        if (recentLogs.isEmpty) {
          return _buildEmptyCard(
            context,
            'No Health Logs',
            'Start tracking your health by adding your first log entry',
            Icons.analytics,
            AppColors.accentColor,
            () => _navigateToHealthLogs(context),
          );
        }

        return Container(
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: AppColors.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recent Health Logs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToHealthLogs(context),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: recentLogs
                    .take(3)
                    .map((log) => _buildHealthLogItem(log))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Upcoming Appointments Card Widget
  static Widget buildUpcomingAppointmentsCard(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, appointmentsProvider, child) {
        final upcomingAppointments = appointmentsProvider.upcomingAppointments;

        if (upcomingAppointments.isEmpty) {
          return _buildEmptyCard(
            context,
            'No Upcoming Appointments',
            'Schedule your next appointment to stay on top of your health',
            Icons.calendar_today,
            AppColors.secondaryColor,
            () => _navigateToAppointments(context),
          );
        }

        return Container(
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: AppColors.secondaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Upcoming Appointments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToAppointments(context),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: upcomingAppointments
                    .take(2)
                    .map((appointment) => _buildAppointmentItem(appointment))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // Health Tips Card Widget
  static Widget buildHealthTipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Health Tip of the Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Stay hydrated by drinking at least 8 glasses of water daily. Proper hydration helps your body function optimally and can improve your energy levels.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.favorite,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Helpful tip from MyMedBuddy',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showMoreHealthTips(context),
                child: const Text(
                  'More Tips',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Today's Summary Widget
  static Widget buildTodaysSummary(BuildContext context) {
    return Consumer3<
      MedicationProvider,
      HealthLogsProvider,
      AppointmentsProvider
    >(
      builder:
          (
            context,
            medicationProvider,
            healthLogsProvider,
            appointmentsProvider,
            child,
          ) {
            final todaysMedications = medicationProvider.todaysMedications;
            final todaysAppointments = appointmentsProvider.todaysAppointments;
            final todaysLogs = healthLogsProvider.healthLogs.where((log) {
              final today = DateTime.now();
              return log.date.year == today.year &&
                  log.date.month == today.month &&
                  log.date.day == today.day;
            }).toList();

            return Container(
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
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.today,
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
                              'Today\'s Summary',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'EEEE, MMMM dd',
                              ).format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Medications',
                          todaysMedications.length.toString(),
                          Icons.medication,
                          AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryItem(
                          'Appointments',
                          todaysAppointments.length.toString(),
                          Icons.calendar_today,
                          AppColors.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryItem(
                          'Health Logs',
                          todaysLogs.length.toString(),
                          Icons.analytics,
                          AppColors.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
    );
  }

  // Helper Methods
  static Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEmptyCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
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
        children: [
          Icon(icon, size: 48, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(text: 'Get Started', onPressed: onTap, icon: Icons.add),
        ],
      ),
    );
  }

  static Widget _buildHealthLogItem(HealthLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getHealthLogTypeColor(log.type),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(log.type.icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, h:mm a').format(log.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildAppointmentItem(AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.doctorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${appointment.formattedDate} at ${appointment.formattedTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Navigation Methods
  static void _navigateToMedications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MedicationScheduleScreen()),
    );
  }

  static void _navigateToHealthLogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthLogsScreen()),
    );
  }

  static void _navigateToAppointments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
    );
  }

  // Utility Methods
  static Color _getMedicationColor(String colorKey) {
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

  static Color _getHealthLogTypeColor(HealthLogType type) {
    switch (type) {
      case HealthLogType.vitals:
        return const Color(0xFFE53E3E);
      case HealthLogType.symptoms:
        return const Color(0xFFFF8C00);
      case HealthLogType.mood:
        return const Color(0xFF9F7AEA);
      case HealthLogType.exercise:
        return const Color(0xFF38A169);
      case HealthLogType.sleep:
        return const Color(0xFF4299E1);
      case HealthLogType.general:
        return AppColors.primaryColor;
    }
  }

  static DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  // Dialog Methods
  static void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('You have no new notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showMoreHealthTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Tips'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Drink at least 8 glasses of water daily\n'
                '• Get 7-9 hours of sleep each night\n'
                '• Exercise regularly for 30 minutes\n'
                '• Eat a balanced diet with fruits and vegetables\n'
                '• Take medications as prescribed\n'
                '• Regular check-ups with your doctor\n'
                '• Manage stress through relaxation techniques\n'
                '• Avoid smoking and excessive alcohol',
                style: TextStyle(height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
