// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:my_medbuddy/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/health_log_model.dart';
import '../../models/appointment_model.dart';
import '../../models/medication_model.dart';
import '../../services/shared_prefs_service.dart';
import '../../providers/medication_provider.dart';
import '../../providers/health_logs_provider.dart';
import '../../providers/appointments_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/dialogs/notification_dialog.dart';
import '../medication/medication_schedule_screnn.dart';
import '../health_logs/health_logs_screen.dart';
import '../appointments/apointments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _initializeProviders();
    });
  }

  Future<void> _loadUserData() async {
    final user = SharedPrefsService.getUserData();
    setState(() {
      _user = user;
    });
  }

  Future<void> _initializeProviders() async {
    final medicationProvider = Provider.of<MedicationProvider>(
      context,
      listen: false,
    );
    final healthLogsProvider = Provider.of<HealthLogsProvider>(
      context,
      listen: false,
    );
    final appointmentsProvider = Provider.of<AppointmentsProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      medicationProvider.loadMedications(),
      healthLogsProvider.loadHealthLogs(),
      appointmentsProvider.loadAppointments(),
    ]);
  }

  void _showNotificationDialog() {
    NotificationDialog.show(context);
  }

  int _getNotificationCount() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    int count = 0;

    // Count active notification types
    if (userProvider.medicationReminders) count++;
    if (userProvider.notificationsEnabled) count++;
    if (userProvider.dailyLogReminderEnabled) count++;

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : AppColors.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
                )
              : AppColors.backgroundGradient,
        ),
        child: SafeArea(child: _buildBody()),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(isDark);
      case 1:
        return const MedicationScheduleScreen();
      case 2:
        return const HealthLogsScreen();
      case 3:
        return const AppointmentsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildDashboard(isDark);
    }
  }

  Widget _buildDashboard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
              )
            : AppColors.backgroundGradient,
      ),
      child: Column(
        children: [
          _buildDashboardHeader(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(isDark),
                  const SizedBox(height: 20),
                  _buildNextMedicationCard(isDark),
                  const SizedBox(height: 20),
                  _buildRecentHealthLogs(isDark),
                  const SizedBox(height: 20),
                  _buildUpcomingAppointments(isDark),
                  const SizedBox(height: 20),
                  _buildDailyHealthTip(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAA7DFF), Color(0xFFC49DFF), Color(0xFFD9BCFF)],
          stops: [0.0, 0.7, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with profile and notification
                Row(
                  children: [
                    // Profile section
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 4;
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _user?.name ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Notification button
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final notificationCount = _getNotificationCount();
                        final hasActiveNotifications =
                            userProvider.medicationReminders ||
                            userProvider.notificationsEnabled ||
                            userProvider.dailyLogReminderEnabled;

                        return GestureDetector(
                          onTap: _showNotificationDialog,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: hasActiveNotifications
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: hasActiveNotifications
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    hasActiveNotifications
                                        ? Icons.notifications
                                        : Icons.notifications_off_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                if (hasActiveNotifications)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$notificationCount',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom greeting section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Track your health journey',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isDark) {
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
                    '${medicationProvider.medications.length}',
                    Icons.medication,
                    AppColors.primaryColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Appointments',
                    '${appointmentsProvider.totalAppointments}',
                    Icons.calendar_today,
                    AppColors.secondaryColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Health Logs',
                    '${healthLogsProvider.healthLogs.length}',
                    Icons.favorite,
                    AppColors.accentColor,
                    isDark,
                  ),
                ),
              ],
            );
          },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextMedicationCard(bool isDark) {
    return Consumer<MedicationProvider>(
      builder: (context, medicationProvider, child) {
        final nextMedication = medicationProvider.nextMedication;

        if (nextMedication == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Medication',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        'No medications scheduled',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Add your medications to get started',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate time until next dose
        final now = DateTime.now();
        final nextDoseTime = _getNextDoseTime(nextMedication, now);
        final difference = nextDoseTime.difference(now);

        String timeUntilNext;
        if (difference.inMinutes < 60) {
          timeUntilNext = 'Due in ${difference.inMinutes} min';
        } else if (difference.inHours < 24) {
          timeUntilNext =
              'Due in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
        } else {
          timeUntilNext = 'Due ${DateFormat('MMM d').format(nextDoseTime)}';
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
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
                    const Text(
                      'Next Medication',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      '${nextMedication.name} - ${nextMedication.dosage}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      timeUntilNext,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(nextDoseTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentHealthLogs(bool isDark) {
    return Consumer<HealthLogsProvider>(
      builder: (context, healthLogsProvider, child) {
        final recentLogs = healthLogsProvider.recentLogs.take(3).toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                  const Icon(
                    Icons.favorite,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Health Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2; // Navigate to Health Logs tab
                      });
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.note_add,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No health logs yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start tracking your health journey',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentLogs.map(
                  (log) => _buildHealthLogItem(
                    log.title,
                    DateFormat('MMM dd').format(log.date),
                    _getHealthLogTypeColor(log.type),
                    isDark,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthLogItem(
    String title,
    String date,
    Color color,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(bool isDark) {
    return Consumer<AppointmentsProvider>(
      builder: (context, appointmentsProvider, child) {
        final upcomingAppointments = appointmentsProvider.upcomingAppointments
            .take(2)
            .toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Appointments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3; // Navigate to Appointments tab
                      });
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (upcomingAppointments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No upcoming appointments',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Schedule your next appointment',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...upcomingAppointments.map(
                  (appointment) => _buildAppointmentItem(appointment, isDark),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppointmentItem(AppointmentModel appointment, bool isDark) {
    final now = DateTime.now();
    final appointmentDate = appointment.dateTime;
    final isToday =
        appointmentDate.day == now.day &&
        appointmentDate.month == now.month &&
        appointmentDate.year == now.year;
    final isTomorrow =
        appointmentDate.day == now.add(const Duration(days: 1)).day &&
        appointmentDate.month == now.add(const Duration(days: 1)).month &&
        appointmentDate.year == now.add(const Duration(days: 1)).year;

    String dateText;
    if (isToday) {
      dateText = 'Today, ${DateFormat('h:mm a').format(appointmentDate)}';
    } else if (isTomorrow) {
      dateText = 'Tomorrow, ${DateFormat('h:mm a').format(appointmentDate)}';
    } else {
      dateText = DateFormat('MMM dd, h:mm a').format(appointmentDate);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${appointment.doctorName} - ${appointment.specialty}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHealthTip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Health Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay hydrated! Drink at least 8 glasses of water daily to maintain optimal health.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthLogTypeColor(HealthLogType type) {
    switch (type) {
      case HealthLogType.vitals:
        return Colors.red;
      case HealthLogType.symptoms:
        return Colors.orange;
      case HealthLogType.mood:
        return Colors.blue;
      case HealthLogType.exercise:
        return Colors.green;
      case HealthLogType.sleep:
        return Colors.purple;
      case HealthLogType.general:
        return AppColors.primaryColor;
    }
  }

  DateTime _getNextDoseTime(MedicationModel medication, DateTime now) {
    DateTime? nextTime;

    for (final timeStr in medication.times) {
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create today's dose time
      final todayDoseTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (todayDoseTime.isAfter(now)) {
        // This dose is still upcoming today
        if (nextTime == null || todayDoseTime.isBefore(nextTime)) {
          nextTime = todayDoseTime;
        }
      } else {
        // This dose has passed today, check tomorrow
        final tomorrowDoseTime = DateTime(
          now.year,
          now.month,
          now.day + 1,
          hour,
          minute,
        );
        if (nextTime == null || tomorrowDoseTime.isBefore(nextTime)) {
          nextTime = tomorrowDoseTime;
        }
      }
    }

    // If no next time found, return the first dose time tomorrow
    if (nextTime == null && medication.times.isNotEmpty) {
      final firstTimeStr = medication.times.first;
      final timeParts = firstTimeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      nextTime = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }

    return nextTime ?? now.add(const Duration(hours: 1));
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Health Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
