// lib/screens/medication/medication_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/medication_provider.dart';
import '../../models/medication_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/medication/medication_card.dart';
import 'add_medication_screen.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({Key? key}) : super(key: key);

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final medicationProvider = Provider.of<MedicationProvider>(
      context,
      listen: false,
    );
    await medicationProvider.loadMedications();

    // Add sample data if no medications exist
    if (medicationProvider.medications.isEmpty) {
      await medicationProvider.addSampleMedications();
    }

    setState(() {
      _isInitialized = true;
    });
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
        title: const Text(
          'Medications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () => _navigateToAddMedication(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: !_isInitialized
          ? const LoadingSpinner()
          : Consumer<MedicationProvider>(
              builder: (context, medicationProvider, child) {
                if (medicationProvider.isLoading) {
                  return const LoadingSpinner();
                }

                if (medicationProvider.error != null) {
                  return _buildErrorState(medicationProvider.error!);
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(medicationProvider),
                    _buildAllMedicationsTab(medicationProvider),
                    _buildHistoryTab(medicationProvider),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMedication,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayTab(MedicationProvider provider) {
    final todaysMeds = provider.todaysMedications;

    if (todaysMeds.isEmpty) {
      return _buildEmptyState(
        'No medications scheduled for today',
        'Add your first medication to get started',
        Icons.medication,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => provider.loadMedications(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTodaysSummary(provider),
          const SizedBox(height: 20),
          _buildTodaysSchedule(todaysMeds),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary(MedicationProvider provider) {
    final nextMed = provider.nextMedication;
    final missedCount = provider.missedDosesToday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (nextMed != null) ...[
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Next: ${nextMed.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.todaysMedications.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Medications Today',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (missedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    '$missedCount Missed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSchedule(List<MedicationModel> medications) {
    final now = DateTime.now();
    final List<_ScheduleItem> scheduleItems = [];

    for (final med in medications) {
      for (final timeStr in med.times) {
        final time = _parseTimeString(timeStr);
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        final log = med.logs.firstWhere(
          (log) =>
              log.scheduledTime.day == now.day &&
              log.scheduledTime.month == now.month &&
              log.scheduledTime.year == now.year &&
              log.scheduledTime.hour == time.hour &&
              log.scheduledTime.minute == time.minute,
          orElse: () => MedicationLog(
            id: '',
            medicationId: med.id,
            scheduledTime: scheduledDateTime,
          ),
        );

        scheduleItems.add(
          _ScheduleItem(
            medication: med,
            scheduledTime: scheduledDateTime,
            log: log.id.isNotEmpty ? log : null,
          ),
        );
      }
    }

    scheduleItems.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scheduleItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = scheduleItems[index];
            return _buildScheduleItem(item);
          },
        ),
      ],
    );
  }

  Widget _buildScheduleItem(_ScheduleItem item) {
    final isOverdue =
        item.scheduledTime.isBefore(DateTime.now()) &&
        (item.log == null || (!item.log!.isTaken && !item.log!.isSkipped));
    final isTaken = item.log?.isTaken ?? false;
    final isSkipped = item.log?.isSkipped ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? AppColors.errorColor
              : isTaken
              ? AppColors.successColor
              : AppColors.lightColor,
          width: isOverdue || isTaken ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getMedicationColor(
                item.medication.color,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: _getMedicationColor(item.medication.color),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.medication.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(item.scheduledTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isOverdue
                            ? AppColors.errorColor
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.medication.dosage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.medication.instructions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.medication.instructions,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isTaken)
            const Icon(
              Icons.check_circle,
              color: AppColors.successColor,
              size: 24,
            )
          else if (isSkipped)
            const Icon(Icons.cancel, color: AppColors.errorColor, size: 24)
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.successColor),
                  onPressed: () => _markAsTaken(item),
                  tooltip: 'Mark as taken',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.errorColor),
                  onPressed: () => _markAsSkipped(item),
                  tooltip: 'Mark as skipped',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAllMedicationsTab(MedicationProvider provider) {
    final medications = provider.activeMedications;

    if (medications.isEmpty) {
      return _buildEmptyState(
        'No medications added yet',
        'Add your first medication to start tracking',
        Icons.medication,
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => provider.loadMedications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final medication = medications[index];
          return MedicationCard(
            medication: medication,
            onTap: () => _showMedicationDetails(medication),
            onEdit: () => _editMedication(medication),
            onDelete: () => _deleteMedication(medication),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab(MedicationProvider provider) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.lightColor),
          SizedBox(height: 16),
          Text(
            'Medication History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.lightColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Medication',
              onPressed: _navigateToAddMedication,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Try Again',
              onPressed: () {
                final provider = Provider.of<MedicationProvider>(
                  context,
                  listen: false,
                );
                provider.clearError();
                provider.loadMedications();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMedicationColor(String colorName) {
    switch (colorName) {
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

  DateTime _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<void> _markAsTaken(_ScheduleItem item) async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.logMedication(
      medicationId: item.medication.id,
      scheduledTime: item.scheduledTime,
      isTaken: true,
    );
  }

  Future<void> _markAsSkipped(_ScheduleItem item) async {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    await provider.logMedication(
      medicationId: item.medication.id,
      scheduledTime: item.scheduledTime,
      isSkipped: true,
      isTaken: false,
    );
  }

  void _navigateToAddMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
    );
  }

  void _editMedication(MedicationModel medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(medication: medication),
      ),
    );
  }

  Future<void> _deleteMedication(MedicationModel medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.name}?'),
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
      final provider = Provider.of<MedicationProvider>(context, listen: false);
      await provider.deleteMedication(medication.id);
    }
  }

  void _showMedicationDetails(MedicationModel medication) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _MedicationDetailsBottomSheet(medication: medication),
    );
  }
}

class _ScheduleItem {
  final MedicationModel medication;
  final DateTime scheduledTime;
  final MedicationLog? log;

  _ScheduleItem({
    required this.medication,
    required this.scheduledTime,
    this.log,
  });
}

class _MedicationDetailsBottomSheet extends StatelessWidget {
  final MedicationModel medication;

  const _MedicationDetailsBottomSheet({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.lightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.medication,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              medication.dosage,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildDetailRow('Frequency', medication.frequency),
                  _buildDetailRow('Times', medication.times.join(', ')),
                  if (medication.instructions.isNotEmpty)
                    _buildDetailRow('Instructions', medication.instructions),
                  _buildDetailRow(
                    'Start Date',
                    DateFormat('MMM dd, yyyy').format(medication.startDate),
                  ),
                  if (medication.endDate != null)
                    _buildDetailRow(
                      'End Date',
                      DateFormat('MMM dd, yyyy').format(medication.endDate!),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Edit',
                          isOutlined: true,
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddMedicationScreen(medication: medication),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Delete',
                          onPressed: () async {
                            Navigator.pop(context);
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Medication'),
                                content: Text(
                                  'Are you sure you want to delete ${medication.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.errorColor,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              final provider = Provider.of<MedicationProvider>(
                                context,
                                listen: false,
                              );
                              await provider.deleteMedication(medication.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
