// lib/widgets/medication/medication_time_picker.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MedicationTimePicker extends StatefulWidget {
  final List<TimeOfDay> selectedTimes;
  final Function(List<TimeOfDay>) onTimesChanged;
  final String? title;
  final int maxTimes;
  final bool allowMultiple;

  const MedicationTimePicker({
    Key? key,
    required this.selectedTimes,
    required this.onTimesChanged,
    this.title,
    this.maxTimes = 6,
    this.allowMultiple = true,
  }) : super(key: key);

  @override
  State<MedicationTimePicker> createState() => _MedicationTimePickerState();
}

class _MedicationTimePickerState extends State<MedicationTimePicker> {
  late List<TimeOfDay> _times;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.selectedTimes);
    if (_times.isEmpty) {
      _times.add(const TimeOfDay(hour: 8, minute: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
        _buildTimeList(),
        const SizedBox(height: 16),
        _buildAddTimeButton(),
        const SizedBox(height: 12),
        _buildQuickPresets(),
      ],
    );
  }

  Widget _buildTimeList() {
    return Column(
      children: _times.asMap().entries.map((entry) {
        final index = entry.key;
        final time = entry.value;
        return _buildTimeItem(index, time);
      }).toList(),
    );
  }

  Widget _buildTimeItem(int index, TimeOfDay time) {
    final timeString = _formatTime(time);
    final isFirst = index == 0;
    final canRemove = _times.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTimeIcon(time),
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
                  timeString,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getTimeLabel(time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editTime(index),
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                tooltip: 'Edit time',
              ),
              if (canRemove)
                IconButton(
                  onPressed: () => _removeTime(index),
                  icon: const Icon(
                    Icons.delete,
                    color: AppColors.errorColor,
                    size: 20,
                  ),
                  tooltip: 'Remove time',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddTimeButton() {
    final canAddMore = _times.length < widget.maxTimes && widget.allowMultiple;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canAddMore ? _addTime : null,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          canAddMore
              ? 'Add Another Time'
              : 'Maximum ${widget.maxTimes} times allowed',
          style: const TextStyle(fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: canAddMore
              ? AppColors.primaryColor
              : AppColors.textSecondary,
          side: BorderSide(
            color: canAddMore
                ? AppColors.primaryColor
                : AppColors.textSecondary.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Presets',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip('Once Daily', [
              const TimeOfDay(hour: 8, minute: 0),
            ]),
            _buildPresetChip('Twice Daily', [
              const TimeOfDay(hour: 8, minute: 0),
              const TimeOfDay(hour: 20, minute: 0),
            ]),
            _buildPresetChip('Three Times', [
              const TimeOfDay(hour: 8, minute: 0),
              const TimeOfDay(hour: 14, minute: 0),
              const TimeOfDay(hour: 20, minute: 0),
            ]),
            _buildPresetChip('Four Times', [
              const TimeOfDay(hour: 8, minute: 0),
              const TimeOfDay(hour: 12, minute: 0),
              const TimeOfDay(hour: 16, minute: 0),
              const TimeOfDay(hour: 20, minute: 0),
            ]),
            _buildPresetChip('With Meals', [
              const TimeOfDay(hour: 7, minute: 30), // Breakfast
              const TimeOfDay(hour: 12, minute: 30), // Lunch
              const TimeOfDay(hour: 18, minute: 30), // Dinner
            ]),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, List<TimeOfDay> times) {
    final isSelected = _timesEqual(_times, times);

    return GestureDetector(
      onTap: () => _applyPreset(times),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : AppColors.lightColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _addTime() {
    if (_times.length < widget.maxTimes) {
      // Find a good default time (1 hour after the last time)
      final lastTime = _times.last;
      final newHour = (lastTime.hour + 1) % 24;
      final newTime = TimeOfDay(hour: newHour, minute: lastTime.minute);

      setState(() {
        _times.add(newTime);
        _sortTimes();
      });
      _notifyChange();
    }
  }

  void _removeTime(int index) {
    if (_times.length > 1) {
      setState(() {
        _times.removeAt(index);
      });
      _notifyChange();
    }
  }

  Future<void> _editTime(int index) async {
    final currentTime = _times[index];
    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialHandColor: AppColors.primaryColor,
              hourMinuteTextColor: AppColors.textPrimary,
              dialTextColor: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _times[index] = newTime;
        _sortTimes();
      });
      _notifyChange();
    }
  }

  void _applyPreset(List<TimeOfDay> preset) {
    setState(() {
      _times = List.from(preset);
    });
    _notifyChange();
  }

  void _sortTimes() {
    _times.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  void _notifyChange() {
    widget.onTimesChanged(_times);
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  String _getTimeLabel(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  IconData _getTimeIcon(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny;
    } else if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined;
    } else if (hour >= 17 && hour < 21) {
      return Icons.wb_twilight;
    } else {
      return Icons.nights_stay;
    }
  }

  bool _timesEqual(List<TimeOfDay> times1, List<TimeOfDay> times2) {
    if (times1.length != times2.length) return false;

    final sorted1 = List<TimeOfDay>.from(times1)..sort(_compareTime);
    final sorted2 = List<TimeOfDay>.from(times2)..sort(_compareTime);

    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i].hour != sorted2[i].hour ||
          sorted1[i].minute != sorted2[i].minute) {
        return false;
      }
    }
    return true;
  }

  int _compareTime(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }
}

// Compact version for forms
class CompactTimePicker extends StatelessWidget {
  final List<TimeOfDay> selectedTimes;
  final Function(List<TimeOfDay>) onTimesChanged;
  final String? label;

  const CompactTimePicker({
    Key? key,
    required this.selectedTimes,
    required this.onTimesChanged,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return _buildTimeChip(context, index, time);
            }),
            _buildAddChip(context),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeChip(BuildContext context, int index, TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _editTime(context, index),
            child: Text(
              time.format(context),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (selectedTimes.length > 1) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removeTime(index),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddChip(BuildContext context) {
    return GestureDetector(
      onTap: () => _addTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 4),
            Text(
              'Add Time',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTime(BuildContext context, int index) async {
    final currentTime = selectedTimes[index];
    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (newTime != null) {
      final updatedTimes = List<TimeOfDay>.from(selectedTimes);
      updatedTimes[index] = newTime;
      onTimesChanged(updatedTimes);
    }
  }

  void _removeTime(int index) {
    if (selectedTimes.length > 1) {
      final updatedTimes = List<TimeOfDay>.from(selectedTimes);
      updatedTimes.removeAt(index);
      onTimesChanged(updatedTimes);
    }
  }

  Future<void> _addTime(BuildContext context) async {
    final newTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (newTime != null) {
      final updatedTimes = List<TimeOfDay>.from(selectedTimes);
      updatedTimes.add(newTime);
      onTimesChanged(updatedTimes);
    }
  }
}
