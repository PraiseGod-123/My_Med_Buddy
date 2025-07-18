import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/health_log_model.dart';

class HealthLogCard extends StatelessWidget {
  final HealthLogModel log;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HealthLogCard({
    Key? key,
    required this.log,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(log.type.icon, color: _getTypeColor(), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd • HH:mm').format(log.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTypeChip(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 18,
                            color: AppColors.errorColor,
                          ),
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
            ),
            const SizedBox(height: 12),
            Text(
              log.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (log.metrics.isNotEmpty ||
                log.symptoms.isNotEmpty ||
                log.mood != null) ...[
              const SizedBox(height: 12),
              _buildQuickInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getTypeColor().withOpacity(0.3)),
      ),
      child: Text(
        log.type.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    final List<Widget> infoWidgets = [];

    if (log.mood != null) {
      infoWidgets.add(_buildInfoChip(Icons.mood, log.mood!));
    }

    if (log.metrics.isNotEmpty) {
      final firstMetric = log.metrics.entries.first;
      infoWidgets.add(
        _buildInfoChip(
          Icons.analytics,
          '${firstMetric.key}: ${firstMetric.value}',
        ),
      );
    }

    if (log.symptoms.isNotEmpty) {
      infoWidgets.add(
        _buildInfoChip(Icons.healing, '${log.symptoms.length} symptoms'),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: infoWidgets.take(2).toList(),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (log.type) {
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
}
