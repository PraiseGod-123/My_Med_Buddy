import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/health_logs_provider.dart';
import '../../models/health_log_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_spinner.dart';
import '../../widgets/health_logs/health_log_card.dart';
import 'add_health_log_screen.dart';

class HealthLogsScreen extends StatefulWidget {
  const HealthLogsScreen({Key? key}) : super(key: key);

  @override
  State<HealthLogsScreen> createState() => _HealthLogsScreenState();
}

class _HealthLogsScreenState extends State<HealthLogsScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final healthLogsProvider = Provider.of<HealthLogsProvider>(
      context,
      listen: false,
    );
    await healthLogsProvider.loadHealthLogs();

    // Add sample data if no logs exist
    if (healthLogsProvider.healthLogs.isEmpty) {
      await healthLogsProvider.addSampleHealthLogs();
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Health Logs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: () => _navigateToAddLog(),
          ),
        ],
      ),
      body: !_isInitialized
          ? const LoadingSpinner()
          : Consumer<HealthLogsProvider>(
              builder: (context, healthLogsProvider, child) {
                if (healthLogsProvider.isLoading) {
                  return const LoadingSpinner();
                }

                if (healthLogsProvider.error != null) {
                  return _buildErrorState(healthLogsProvider.error!);
                }

                return Column(
                  children: [
                    _buildFilterChips(healthLogsProvider),
                    Expanded(child: _buildLogsList(healthLogsProvider)),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips(HealthLogsProvider provider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(null, 'All', provider),
          const SizedBox(width: 8),
          ...HealthLogType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(type, type.displayName, provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    HealthLogType? type,
    String label,
    HealthLogsProvider provider,
  ) {
    final isSelected = provider.filterType == type;
    final count = type != null
        ? provider.logCountsByType[type] ?? 0
        : provider.healthLogs.length;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        provider.setFilter(selected ? type : null);
      },
      label: Text('$label ($count)'),
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLogsList(HealthLogsProvider provider) {
    final logs = provider.healthLogs;

    if (logs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () => provider.loadHealthLogs(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final log = logs[index];
          return HealthLogCard(
            log: log,
            onTap: () => _showLogDetails(log),
            onEdit: () => _editLog(log),
            onDelete: () => _deleteLog(log),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add, size: 80, color: AppColors.lightColor),
            const SizedBox(height: 24),
            const Text(
              'No health logs yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start tracking your health by adding your first log entry',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Health Log',
              onPressed: _navigateToAddLog,
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
                final provider = Provider.of<HealthLogsProvider>(
                  context,
                  listen: false,
                );
                provider.clearError();
                provider.loadHealthLogs();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHealthLogScreen()),
    );
  }

  void _editLog(HealthLogModel log) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHealthLogScreen(log: log)),
    );
  }

  Future<void> _deleteLog(HealthLogModel log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Log'),
        content: Text('Are you sure you want to delete "${log.title}"?'),
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
      final provider = Provider.of<HealthLogsProvider>(context, listen: false);
      await provider.deleteHealthLog(log.id);
    }
  }

  void _showLogDetails(HealthLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HealthLogDetailsBottomSheet(log: log),
    );
  }
}

class _HealthLogDetailsBottomSheet extends StatelessWidget {
  final HealthLogModel log;

  const _HealthLogDetailsBottomSheet({required this.log});

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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          log.type.icon,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy • HH:mm',
                              ).format(log.date),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection('Type', log.type.displayName),
                  _buildDetailSection('Description', log.description),
                  if (log.metrics.isNotEmpty) _buildMetricsSection(),
                  if (log.mood != null) _buildDetailSection('Mood', log.mood!),
                  if (log.symptoms.isNotEmpty)
                    _buildDetailSection('Symptoms', log.symptoms.join(', ')),
                  if (log.notes != null && log.notes!.isNotEmpty)
                    _buildDetailSection('Notes', log.notes!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metrics',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...log.metrics.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key.replaceAll('_', ' ').toLowerCase()}:',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
