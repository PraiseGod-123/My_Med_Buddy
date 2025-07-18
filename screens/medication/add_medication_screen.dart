import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddMedicationScreen extends StatefulWidget {
  final MedicationModel? medication;

  const AddMedicationScreen({Key? key, this.medication}) : super(key: key);

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedFrequency = 'Once daily';
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _selectedColor = 'primary';
  bool _isLoading = false;

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
  ];

  final Map<String, Color> _colors = {
    'primary': AppColors.primaryColor,
    'secondary': AppColors.secondaryColor,
    'accent': AppColors.accentColor,
  };

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final med = widget.medication!;
    _nameController.text = med.name;
    _dosageController.text = med.dosage;
    _instructionsController.text = med.instructions;
    _selectedFrequency = med.frequency;
    _startDate = med.startDate;
    _endDate = med.endDate;
    _selectedColor = med.color;

    _selectedTimes = med.times.map((timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Medication' : 'Add Medication',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Medication Name',
                hint: 'Enter medication name',
                controller: _nameController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Medication name'),
                prefixIcon: const Icon(Icons.medication),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Dosage',
                hint: 'e.g., 500mg, 1 tablet',
                controller: _dosageController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Dosage'),
                prefixIcon: const Icon(Icons.straighten),
              ),
              const SizedBox(height: 20),
              _buildFrequencySelector(),
              const SizedBox(height: 20),
              _buildTimeSelector(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 20),
              _buildColorSelector(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Instructions (Optional)',
                hint: 'Take with food, before bed, etc.',
                controller: _instructionsController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.notes),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: isEditing ? 'Update Medication' : 'Add Medication',
                isLoading: _isLoading,
                onPressed: _saveMedication,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFrequency,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _selectedFrequency = value!;
                  _updateTimesForFrequency();
                });
              },
              items: _frequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Times',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (_selectedTimes.length < 4)
              TextButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Time'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_selectedTimes.length, (index) {
            return _buildTimeChip(index);
          }),
        ),
      ],
    );
  }

  Widget _buildTimeChip(int index) {
    final time = _selectedTimes[index];
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

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
            onTap: () => _editTime(index),
            child: Text(
              timeStr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (_selectedTimes.length > 1) ...[
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                'Start Date',
                _startDate,
                (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                'End Date (Optional)',
                _endDate,
                (date) => setState(() => _endDate = date),
                canClear: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime) onDateSelected, {
    bool canClear = false,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(onDateSelected),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (canClear && date != null)
                  GestureDetector(
                    onTap: () => setState(() => _endDate = null),
                    child: const Icon(
                      Icons.clear,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color Theme',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _colors.entries.map((entry) {
            final isSelected = _selectedColor == entry.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = entry.key),
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _updateTimesForFrequency() {
    switch (_selectedFrequency) {
      case 'Once daily':
        _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
        break;
      case 'Twice daily':
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Three times daily':
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      case 'Four times daily':
        _selectedTimes = [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 16, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
        break;
      default:
        _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
    }
  }

  void _addTime() {
    setState(() {
      _selectedTimes.add(const TimeOfDay(hour: 8, minute: 0));
    });
  }

  void _removeTime(int index) {
    setState(() {
      _selectedTimes.removeAt(index);
    });
  }

  Future<void> _editTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (time != null) {
      setState(() {
        _selectedTimes[index] = time;
      });
    }
  }

  Future<void> _selectDate(Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      onDateSelected(date);
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final timeStrings = _selectedTimes.map((time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }).toList();

      final medication = MedicationModel(
        id:
            widget.medication?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _selectedFrequency,
        times: timeStrings,
        instructions: _instructionsController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        color: _selectedColor,
        logs: widget.medication?.logs ?? [],
      );

      final provider = Provider.of<MedicationProvider>(context, listen: false);

      if (widget.medication != null) {
        await provider.updateMedication(medication);
      } else {
        await provider.addMedication(medication);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.medication != null
                  ? 'Medication updated successfully'
                  : 'Medication added successfully',
            ),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
