// lib/screens/health_logs/add_health_log_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/health_log_model.dart';
import '../../providers/health_logs_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddHealthLogScreen extends StatefulWidget {
  final HealthLogModel? log;

  const AddHealthLogScreen({Key? key, this.log}) : super(key: key);

  @override
  State<AddHealthLogScreen> createState() => _AddHealthLogScreenState();
}

class _AddHealthLogScreenState extends State<AddHealthLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  HealthLogType _selectedType = HealthLogType.general;
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  List<String> _symptoms = [];
  Map<String, dynamic> _metrics = {};
  bool _isLoading = false;

  // Metric controllers for vitals
  final _bloodPressureSystolicController = TextEditingController();
  final _bloodPressureDiastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weightController = TextEditingController();

  final List<String> _moodOptions = [
    'Excellent',
    'Good',
    'Fair',
    'Poor',
    'Terrible',
  ];

  final List<String> _commonSymptoms = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Dizziness',
    'Fever',
    'Cough',
    'Shortness of breath',
    'Chest pain',
    'Stomach pain',
    'Joint pain',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final log = widget.log!;
    _titleController.text = log.title;
    _descriptionController.text = log.description;
    _notesController.text = log.notes ?? '';
    _selectedType = log.type;
    _selectedDate = log.date;
    _selectedMood = log.mood;
    _symptoms = List.from(log.symptoms);
    _metrics = Map.from(log.metrics);

    // Populate metric controllers
    if (_metrics.containsKey('blood_pressure_systolic')) {
      _bloodPressureSystolicController.text =
          _metrics['blood_pressure_systolic'].toString();
    }
    if (_metrics.containsKey('blood_pressure_diastolic')) {
      _bloodPressureDiastolicController.text =
          _metrics['blood_pressure_diastolic'].toString();
    }
    if (_metrics.containsKey('heart_rate')) {
      _heartRateController.text = _metrics['heart_rate'].toString();
    }
    if (_metrics.containsKey('temperature')) {
      _temperatureController.text = _metrics['temperature'].toString();
    }
    if (_metrics.containsKey('weight')) {
      _weightController.text = _metrics['weight'].toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.log != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Health Log' : 'Add Health Log',
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
                label: 'Title',
                hint: 'Enter log title',
                controller: _titleController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Title'),
                prefixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              _buildDateSelector(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                hint: 'Describe what happened',
                controller: _descriptionController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Description'),
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 20),
              if (_selectedType == HealthLogType.vitals) _buildVitalsSection(),
              if (_selectedType == HealthLogType.mood) _buildMoodSection(),
              if (_selectedType == HealthLogType.symptoms)
                _buildSymptomsSection(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Additional notes',
                controller: _notesController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.notes),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: isEditing ? 'Update Log' : 'Save Log',
                isLoading: _isLoading,
                onPressed: _saveLog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HealthLogType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.lightColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} • ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vital Signs',
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
              child: CustomTextField(
                label: 'Systolic BP',
                hint: '120',
                controller: _bloodPressureSystolicController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Diastolic BP',
                hint: '80',
                controller: _bloodPressureDiastolicController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Heart Rate',
                hint: '72 bpm',
                controller: _heartRateController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Temperature',
                hint: '98.6°F',
                controller: _temperatureController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Weight (Optional)',
          hint: 'Enter weight',
          controller: _weightController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _moodOptions.map((mood) {
            final isSelected = _selectedMood == mood;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedMood = isSelected ? null : mood),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.secondaryColor
                        : AppColors.lightColor,
                  ),
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonSymptoms.map((symptom) {
            final isSelected = _symptoms.contains(symptom);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _symptoms.remove(symptom);
                  } else {
                    _symptoms.add(symptom);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.errorColor : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.errorColor
                        : AppColors.lightColor,
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _updateMetrics() {
    _metrics.clear();

    if (_selectedType == HealthLogType.vitals) {
      if (_bloodPressureSystolicController.text.isNotEmpty) {
        _metrics['blood_pressure_systolic'] =
            int.tryParse(_bloodPressureSystolicController.text) ?? 0;
      }
      if (_bloodPressureDiastolicController.text.isNotEmpty) {
        _metrics['blood_pressure_diastolic'] =
            int.tryParse(_bloodPressureDiastolicController.text) ?? 0;
      }
      if (_heartRateController.text.isNotEmpty) {
        _metrics['heart_rate'] = int.tryParse(_heartRateController.text) ?? 0;
      }
      if (_temperatureController.text.isNotEmpty) {
        _metrics['temperature'] =
            double.tryParse(_temperatureController.text) ?? 0.0;
      }
      if (_weightController.text.isNotEmpty) {
        _metrics['weight'] = double.tryParse(_weightController.text) ?? 0.0;
      }
    }
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _updateMetrics();

      final log = HealthLogModel(
        id: widget.log?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        metrics: _metrics,
        mood: _selectedMood,
        symptoms: _symptoms,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final provider = Provider.of<HealthLogsProvider>(context, listen: false);

      if (widget.log != null) {
        await provider.updateHealthLog(log);
      } else {
        await provider.addHealthLog(log);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.log != null
                  ? 'Health log updated successfully'
                  : 'Health log added successfully',
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
