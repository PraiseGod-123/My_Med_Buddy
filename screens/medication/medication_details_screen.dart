// lib/screens/medication/medication_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_spinner.dart';
import 'add_medication_screen.dart';

class MedicationDetailsScreen extends StatefulWidget {
  final MedicationModel medication;

  const MedicationDetailsScreen({Key? key, required this.medication})
    : super(key: key);

  @override
  State<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MedicationModel _currentMedication;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMedication = widget.medication;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _currentMedication.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () => _editMedication(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateMedication();
                  break;
                case 'delete':
                  _deleteMedication();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 18),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.errorColor),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Schedule'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingSpinner()
          : Consumer<MedicationProvider>(
              builder: (context, medicationProvider, child) {
                // Update current medication if it was modified
                final updatedMedication = medicationProvider.medications
                    .firstWhere(
                      (med) => med.id == _currentMedication.id,
                      orElse: () => _currentMedication,
                    );
                _currentMedication = updatedMedication;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(),
                    _buildScheduleTab(),
                    _buildHistoryTab(),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedicationHeader(),
          const SizedBox(height: 24),
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildScheduleInfoCard(),
          const SizedBox(height: 16),
          _buildDurationCard(),
          const SizedBox(height: 16),
          if (_currentMedication.instructions.isNotEmpty)
            _buildInstructionsCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildMedicationHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getMedicationGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getMedicationColor().withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _currentMedication.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _currentMedication.dosage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentMedication.isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildInfoCard('Basic Information', [
      _buildInfoRow('Medication Name', _currentMedication.name),
      _buildInfoRow('Dosage', _currentMedication.dosage),
      _buildInfoRow('Frequency', _currentMedication.frequency),
      _buildInfoRow(
        'Status',
        _currentMedication.isActive ? 'Active' : 'Inactive',
        valueColor: _currentMedication.isActive
            ? AppColors.successColor
            : AppColors.errorColor,
      ),
    ]);
  }

  Widget _buildScheduleInfoCard() {
    return _buildInfoCard('Schedule', [
      _buildInfoRow('Times', _currentMedication.times.join(', ')),
      _buildInfoRow(
        'Next Dose',
        _getNextDoseTime(),
        valueColor: AppColors.primaryColor,
      ),
      _buildInfoRow('Total Daily Doses', '${_currentMedication.times.length}'),
    ]);
  }

  Widget _buildDurationCard() {
    return _buildInfoCard('Duration', [
      _buildInfoRow(
        'Start Date',
        DateFormat('MMM dd, yyyy').format(_currentMedication.startDate),
      ),
      _buildInfoRow(
        'End Date',
        _currentMedication.endDate != null
            ? DateFormat('MMM dd, yyyy').format(_currentMedication.endDate!)
            : 'Ongoing',
      ),
      _buildInfoRow('Days Active', _getDaysActive().toString()),
      if (_currentMedication.endDate != null)
        _buildInfoRow('Days Remaining', _getDaysRemaining().toString()),
    ]);
  }

  Widget _buildInstructionsCard() {
    return _buildInfoCard('Instructions', [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Text(
          _currentMedication.instructions,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    ]);
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayScheduleCard(),
          const SizedBox(height: 16),
          _buildWeeklyScheduleCard(),
          const SizedBox(height: 16),
          _buildScheduleStatsCard(),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleCard() {
    final todayLogs = _getTodayLogs();

    return _buildInfoCard('Today\'s Schedule', [
      ...todayLogs.map((log) => _buildScheduleItem(log)).toList(),
      if (todayLogs.isEmpty)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No doses scheduled for today',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ),
    ]);
  }

  Widget _buildScheduleItem(MedicationLog log) {
    final isOverdue =
        !log.isTaken &&
        !log.isSkipped &&
        log.scheduledTime.isBefore(DateTime.now());
    final isTaken = log.isTaken;
    final isSkipped = log.isSkipped;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTaken
            ? AppColors.successColor.withOpacity(0.1)
            : isSkipped
            ? AppColors.errorColor.withOpacity(0.1)
            : isOverdue
            ? Colors.orange.withOpacity(0.1)
            : AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTaken
              ? AppColors.successColor.withOpacity(0.3)
              : isSkipped
              ? AppColors.errorColor.withOpacity(0.3)
              : isOverdue
              ? Colors.orange.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTaken
                ? Icons.check_circle
                : isSkipped
                ? Icons.cancel
                : isOverdue
                ? Icons.warning
                : Icons.schedule,
            color: isTaken
                ? AppColors.successColor
                : isSkipped
                ? AppColors.errorColor
                : isOverdue
                ? Colors.orange
                : AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(log.scheduledTime),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getLogStatusText(log),
                  style: TextStyle(
                    fontSize: 12,
                    color: isTaken
                        ? AppColors.successColor
                        : isSkipped
                        ? AppColors.errorColor
                        : isOverdue
                        ? Colors.orange
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isTaken && !isSkipped)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.successColor),
                  onPressed: () => _markAsTaken(log),
                  tooltip: 'Mark as taken',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.errorColor),
                  onPressed: () => _markAsSkipped(log),
                  tooltip: 'Mark as skipped',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard() {
    return _buildInfoCard('This Week\'s Schedule', [
      const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.calendar_view_week,
                size: 48,
                color: AppColors.lightColor,
              ),
              SizedBox(height: 12),
              Text(
                'Weekly Schedule View',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Coming Soon',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildScheduleStatsCard() {
    final totalLogs = _currentMedication.logs.length;
    final takenLogs = _currentMedication.logs
        .where((log) => log.isTaken)
        .length;
    final skippedLogs = _currentMedication.logs
        .where((log) => log.isSkipped)
        .length;
    final adherenceRate = totalLogs > 0 ? (takenLogs / totalLogs * 100) : 0;

    return _buildInfoCard('Adherence Statistics', [
      Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Doses',
              totalLogs.toString(),
              AppColors.primaryColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Taken',
              takenLogs.toString(),
              AppColors.successColor,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Missed',
              skippedLogs.toString(),
              AppColors.errorColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getMedicationColor().withOpacity(0.1),
              _getMedicationColor().withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.analytics, color: _getMedicationColor(), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adherence Rate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${adherenceRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getMedicationColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final logs = _currentMedication.logs;

    if (logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppColors.lightColor),
            SizedBox(height: 16),
            Text(
              'No medication history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your medication logs will appear here',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Group logs by date
    final groupedLogs = <String, List<MedicationLog>>{};
    for (final log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.scheduledTime);
      groupedLogs[dateKey] = [...(groupedLogs[dateKey] ?? []), log];
    }

    // Sort dates in descending order
    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final dayLogs = groupedLogs[dateKey]!;
        final date = DateTime.parse(dateKey);

        return _buildHistoryDateGroup(date, dayLogs);
      },
    );
  }

  Widget _buildHistoryDateGroup(DateTime date, List<MedicationLog> logs) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getMedicationColor().withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: _getMedicationColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatHistoryDate(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getMedicationColor(),
                  ),
                ),
                const Spacer(),
                Text(
                  '${logs.where((log) => log.isTaken).length}/${logs.length} taken',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: logs.map((log) => _buildHistoryLogItem(log)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryLogItem(MedicationLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: log.isTaken
            ? AppColors.successColor.withOpacity(0.1)
            : log.isSkipped
            ? AppColors.errorColor.withOpacity(0.1)
            : AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: log.isTaken
              ? AppColors.successColor.withOpacity(0.3)
              : log.isSkipped
              ? AppColors.errorColor.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            log.isTaken
                ? Icons.check_circle
                : log.isSkipped
                ? Icons.cancel
                : Icons.schedule,
            color: log.isTaken
                ? AppColors.successColor
                : log.isSkipped
                ? AppColors.errorColor
                : AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(log.scheduledTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (log.takenTime != null)
                  Text(
                    'Taken at ${DateFormat('h:mm a').format(log.takenTime!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (log.notes != null && log.notes!.isNotEmpty)
                  Text(
                    log.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _getLogStatusText(log),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: log.isTaken
                  ? AppColors.successColor
                  : log.isSkipped
                  ? AppColors.errorColor
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Edit Medication',
                isOutlined: true,
                onPressed: _editMedication,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Quick Log',
                onPressed: _showQuickLogDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.errorColor, width: 2),
          ),
          child: ElevatedButton(
            onPressed: _deleteMedication,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete Medication',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.errorColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getMedicationColor() {
    switch (_currentMedication.color) {
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

  LinearGradient _getMedicationGradient() {
    final color = _getMedicationColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withOpacity(0.8)],
    );
  }

  String _getNextDoseTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final timeStr in _currentMedication.times) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final doseTime = DateTime(
        today.year,
        today.month,
        today.day,
        hour,
        minute,
      );

      if (doseTime.isAfter(now)) {
        return DateFormat('h:mm a').format(doseTime);
      }
    }

    // If no more doses today, return first dose of tomorrow
    if (_currentMedication.times.isNotEmpty) {
      final parts = _currentMedication.times.first.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final tomorrowDose = DateTime(
        today.year,
        today.month,
        today.day + 1,
        hour,
        minute,
      );
      return 'Tomorrow at ${DateFormat('h:mm a').format(tomorrowDose)}';
    }

    return 'No upcoming doses';
  }

  int _getDaysActive() {
    final now = DateTime.now();
    return now.difference(_currentMedication.startDate).inDays;
  }

  int _getDaysRemaining() {
    if (_currentMedication.endDate == null) return 0;
    final now = DateTime.now();
    final remaining = _currentMedication.endDate!.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }

  List<MedicationLog> _getTodayLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _currentMedication.logs
        .where(
          (log) =>
              log.scheduledTime.isAfter(today) &&
              log.scheduledTime.isBefore(tomorrow),
        )
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  String _getLogStatusText(MedicationLog log) {
    if (log.isTaken) {
      return 'Taken';
    } else if (log.isSkipped) {
      return 'Skipped';
    } else if (log.scheduledTime.isBefore(DateTime.now())) {
      return 'Missed';
    } else {
      return 'Scheduled';
    }
  }

  String _formatHistoryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  // Action methods
  void _editMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddMedicationScreen(medication: _currentMedication),
      ),
    );
  }

  void _duplicateMedication() {
    final duplicatedMedication = _currentMedication.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${_currentMedication.name} (Copy)',
      logs: [], // Start with empty logs for the duplicate
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddMedicationScreen(medication: duplicatedMedication),
      ),
    );
  }

  Future<void> _deleteMedication() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text(
          'Are you sure you want to delete ${_currentMedication.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final provider = Provider.of<MedicationProvider>(
          context,
          listen: false,
        );
        await provider.deleteMedication(_currentMedication.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medication deleted successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete medication: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _markAsTaken(MedicationLog log) async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.logMedication(
      medicationId: _currentMedication.id,
      scheduledTime: log.scheduledTime,
      isTaken: true,
    );
  }

  Future<void> _markAsSkipped(MedicationLog log) async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.logMedication(
      medicationId: _currentMedication.id,
      scheduledTime: log.scheduledTime,
      isSkipped: true,
      isTaken: false,
    );
  }

  void _showQuickLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mark this medication as:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Taken Now',
                    onPressed: () {
                      Navigator.pop(context);
                      _logMedicationNow(true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Skipped',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(context);
                      _logMedicationNow(false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _logMedicationNow(bool isTaken) async {
    final now = DateTime.now();
    final provider = Provider.of<MedicationProvider>(context, listen: false);

    await provider.logMedication(
      medicationId: _currentMedication.id,
      scheduledTime: now,
      isTaken: isTaken,
      isSkipped: !isTaken,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTaken
                ? 'Medication marked as taken'
                : 'Medication marked as skipped',
          ),
          backgroundColor: isTaken
              ? AppColors.successColor
              : AppColors.errorColor,
        ),
      );
    }
  }
}
