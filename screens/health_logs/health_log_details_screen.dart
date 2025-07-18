// lib/screens/health_logs/health_log_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/health_log_model.dart';
import '../../providers/health_logs_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'add_health_log_screen.dart';

class HealthLogDetailsScreen extends StatefulWidget {
  final HealthLogModel healthLog;

  const HealthLogDetailsScreen({Key? key, required this.healthLog})
    : super(key: key);

  @override
  State<HealthLogDetailsScreen> createState() => _HealthLogDetailsScreenState();
}

class _HealthLogDetailsScreenState extends State<HealthLogDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HealthLogModel _currentHealthLog;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentHealthLog = widget.healthLog;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshHealthLog() {
    final provider = Provider.of<HealthLogsProvider>(context, listen: false);
    final updatedLog = provider.healthLogs.firstWhere(
      (log) => log.id == _currentHealthLog.id,
      orElse: () => _currentHealthLog,
    );
    setState(() {
      _currentHealthLog = updatedLog;
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
          'Health Log Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppColors.errorColor),
                    SizedBox(width: 12),
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
            Tab(text: 'Overview'),
            Tab(text: 'Details'),
            Tab(text: 'Metrics'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHealthLogHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDetailsTab(),
                _buildMetricsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHealthLogHeader() {
    final daysSinceLogged = DateTime.now()
        .difference(_currentHealthLog.date)
        .inDays;
    final isRecent = daysSinceLogged == 0;
    final isYesterday = daysSinceLogged == 1;

    String timeAgo;
    if (isRecent) {
      final hoursSince = DateTime.now()
          .difference(_currentHealthLog.date)
          .inHours;
      if (hoursSince == 0) {
        final minutesSince = DateTime.now()
            .difference(_currentHealthLog.date)
            .inMinutes;
        timeAgo = minutesSince <= 1 ? 'Just now' : '$minutesSince minutes ago';
      } else {
        timeAgo = hoursSince == 1 ? '1 hour ago' : '$hoursSince hours ago';
      }
    } else if (isYesterday) {
      timeAgo = 'Yesterday';
    } else {
      timeAgo = '$daysSinceLogged days ago';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor().withOpacity(0.1),
            _getTypeColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTypeColor().withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _currentHealthLog.type.icon,
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentHealthLog.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentHealthLog.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: _getTypeColor(),
                        fontWeight: FontWeight.w500,
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
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'MMM dd, yyyy • h:mm a',
                ).format(_currentHealthLog.date),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isRecent
                      ? AppColors.successColor.withOpacity(0.1)
                      : AppColors.lightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: isRecent
                        ? AppColors.successColor
                        : AppColors.textSecondary,
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Description', [
            Text(
              _currentHealthLog.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          if (_currentHealthLog.mood != null)
            _buildInfoCard('Mood', [
              _buildMoodIndicator(_currentHealthLog.mood!),
            ]),
          if (_currentHealthLog.mood != null) const SizedBox(height: 16),
          if (_currentHealthLog.symptoms.isNotEmpty)
            _buildInfoCard('Symptoms', [
              _buildSymptomsChips(_currentHealthLog.symptoms),
            ]),
          if (_currentHealthLog.symptoms.isNotEmpty) const SizedBox(height: 16),
          if (_currentHealthLog.metrics.isNotEmpty)
            _buildInfoCard('Key Metrics', [
              _buildMetricsSummary(_currentHealthLog.metrics),
            ]),
          if (_currentHealthLog.metrics.isNotEmpty) const SizedBox(height: 16),
          if (_currentHealthLog.notes != null &&
              _currentHealthLog.notes!.isNotEmpty)
            _buildInfoCard('Notes', [
              Text(
                _currentHealthLog.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Log Information', [
            _buildDetailRow('ID', _currentHealthLog.id),
            _buildDetailRow('Type', _currentHealthLog.type.displayName),
            _buildDetailRow(
              'Date',
              DateFormat('EEEE, MMMM dd, yyyy').format(_currentHealthLog.date),
            ),
            _buildDetailRow(
              'Time',
              DateFormat('h:mm a').format(_currentHealthLog.date),
            ),
            _buildDetailRow('Title', _currentHealthLog.title),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Content Details', [
            _buildDetailRow('Description', _currentHealthLog.description),
            if (_currentHealthLog.mood != null)
              _buildDetailRow('Mood', _currentHealthLog.mood!),
            if (_currentHealthLog.symptoms.isNotEmpty)
              _buildDetailRow(
                'Symptoms',
                _currentHealthLog.symptoms.join(', '),
              ),
            if (_currentHealthLog.notes != null &&
                _currentHealthLog.notes!.isNotEmpty)
              _buildDetailRow('Notes', _currentHealthLog.notes!),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Metadata', [
            _buildDetailRow(
              'Metrics Count',
              _currentHealthLog.metrics.length.toString(),
            ),
            _buildDetailRow(
              'Symptoms Count',
              _currentHealthLog.symptoms.length.toString(),
            ),
            _buildDetailRow(
              'Has Notes',
              _currentHealthLog.notes != null &&
                      _currentHealthLog.notes!.isNotEmpty
                  ? 'Yes'
                  : 'No',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentHealthLog.metrics.isEmpty)
            _buildEmptyMetricsState()
          else
            _buildMetricsCards(_currentHealthLog.metrics),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

  Widget _buildMoodIndicator(String mood) {
    Color moodColor;
    IconData moodIcon;

    switch (mood.toLowerCase()) {
      case 'excellent':
        moodColor = const Color(0xFF4CAF50);
        moodIcon = Icons.sentiment_very_satisfied;
        break;
      case 'good':
        moodColor = const Color(0xFF8BC34A);
        moodIcon = Icons.sentiment_satisfied;
        break;
      case 'fair':
        moodColor = const Color(0xFFFFEB3B);
        moodIcon = Icons.sentiment_neutral;
        break;
      case 'poor':
        moodColor = const Color(0xFFFF9800);
        moodIcon = Icons.sentiment_dissatisfied;
        break;
      case 'terrible':
        moodColor = const Color(0xFFF44336);
        moodIcon = Icons.sentiment_very_dissatisfied;
        break;
      default:
        moodColor = AppColors.textSecondary;
        moodIcon = Icons.sentiment_neutral;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: moodColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(moodIcon, color: moodColor, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mood,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: moodColor,
                ),
              ),
              const Text(
                'Mood Rating',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsChips(List<String> symptoms) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: symptoms.map((symptom) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, size: 16, color: AppColors.errorColor),
              const SizedBox(width: 4),
              Text(
                symptom,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsSummary(Map<String, dynamic> metrics) {
    return Column(
      children: metrics.entries.take(3).map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getTypeColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatMetricName(entry.key),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                _formatMetricValue(entry.key, entry.value),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsCards(Map<String, dynamic> metrics) {
    return Column(
      children: metrics.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMetricIcon(entry.key),
                  color: _getTypeColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatMetricName(entry.key),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatMetricValue(entry.key, entry.value),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyMetricsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: AppColors.lightColor),
          const SizedBox(height: 16),
          const Text(
            'No Metrics Recorded',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This health log doesn\'t contain any recorded metrics or measurements.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Edit Log',
              isOutlined: true,
              onPressed: _editHealthLog,
              icon: Icons.edit,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Duplicate',
              onPressed: _duplicateHealthLog,
              icon: Icons.copy,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editHealthLog();
        break;
      case 'duplicate':
        _duplicateHealthLog();
        break;
      case 'delete':
        _deleteHealthLog();
        break;
    }
  }

  void _editHealthLog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHealthLogScreen(log: _currentHealthLog),
      ),
    ).then((_) => _refreshHealthLog());
  }

  void _duplicateHealthLog() {
    final duplicatedLog = HealthLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      title: '${_currentHealthLog.title} (Copy)',
      description: _currentHealthLog.description,
      type: _currentHealthLog.type,
      metrics: Map.from(_currentHealthLog.metrics),
      mood: _currentHealthLog.mood,
      symptoms: List.from(_currentHealthLog.symptoms),
      notes: _currentHealthLog.notes,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddHealthLogScreen(log: duplicatedLog),
      ),
    );
  }

  void _deleteHealthLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Health Log'),
        content: const Text(
          'Are you sure you want to delete this health log? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final provider = Provider.of<HealthLogsProvider>(context, listen: false);
    provider
        .deleteHealthLog(_currentHealthLog.id)
        .then((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Health log deleted successfully'),
              backgroundColor: AppColors.successColor,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete health log: $error'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        });
  }

  Color _getTypeColor() {
    switch (_currentHealthLog.type) {
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

  IconData _getMetricIcon(String metricKey) {
    final key = metricKey.toLowerCase();
    if (key.contains('blood_pressure') || key.contains('pressure')) {
      return Icons.monitor_heart;
    } else if (key.contains('heart_rate') || key.contains('pulse')) {
      return Icons.favorite;
    } else if (key.contains('temperature') || key.contains('temp')) {
      return Icons.thermostat;
    } else if (key.contains('weight')) {
      return Icons.scale;
    } else if (key.contains('height')) {
      return Icons.height;
    } else if (key.contains('glucose') || key.contains('sugar')) {
      return Icons.water_drop;
    } else {
      return Icons.analytics;
    }
  }

  String _formatMetricName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  String _formatMetricValue(String key, dynamic value) {
    final keyLower = key.toLowerCase();
    if (keyLower.contains('blood_pressure')) {
      return '$value mmHg';
    } else if (keyLower.contains('heart_rate')) {
      return '$value bpm';
    } else if (keyLower.contains('temperature')) {
      return '$value°F';
    } else if (keyLower.contains('weight')) {
      return '$value lbs';
    } else if (keyLower.contains('height')) {
      return '$value ft';
    } else if (keyLower.contains('glucose')) {
      return '$value mg/dL';
    } else {
      return value.toString();
    }
  }
}
