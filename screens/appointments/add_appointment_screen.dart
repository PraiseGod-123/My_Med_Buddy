// lib/screens/appointments/add_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointments_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class AddAppointmentScreen extends StatefulWidget {
  final AppointmentModel? appointment;

  const AddAppointmentScreen({Key? key, this.appointment}) : super(key: key);

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  AppointmentType _selectedType = AppointmentType.checkup;
  AppointmentStatus _selectedStatus = AppointmentStatus.scheduled;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Duration _selectedDuration = const Duration(minutes: 30);
  bool _isReminderSet = true;
  int _reminderMinutes = 30;
  List<String> _selectedSymptoms = [];
  List<String> _selectedMedications = [];
  bool _isLoading = false;

  final List<String> _specialties = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'Neurology',
    'Oncology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Urology',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Physical Therapy',
    'Radiology',
    'Pathology',
    'Emergency Medicine',
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
    'Back pain',
    'Skin issues',
    'Vision problems',
    'Hearing problems',
    'Sleep issues',
  ];

  final List<Duration> _durations = [
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(minutes: 45),
    const Duration(minutes: 60),
    const Duration(minutes: 90),
    const Duration(minutes: 120),
  ];

  final List<int> _reminderOptions = [15, 30, 60, 120, 1440]; // minutes

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final appointment = widget.appointment!;
    _titleController.text = appointment.title;
    _doctorController.text = appointment.doctorName;
    _specialtyController.text = appointment.specialty;
    _locationController.text = appointment.location;
    _descriptionController.text = appointment.description;
    _notesController.text = appointment.notes;
    _contactController.text = appointment.contactNumber;
    _addressController.text = appointment.address;

    _selectedType = appointment.type;
    _selectedStatus = appointment.status;
    _selectedDate = appointment.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(appointment.dateTime);
    _selectedDuration = appointment.duration;
    _isReminderSet = appointment.isReminderSet;
    _reminderMinutes = appointment.reminderMinutes;
    _selectedSymptoms = List.from(appointment.symptoms);
    _selectedMedications = List.from(appointment.medications);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Appointment' : 'Schedule Appointment',
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
                label: 'Appointment Title',
                hint: 'Enter appointment title',
                controller: _titleController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Title'),
                prefixIcon: const Icon(Icons.event),
              ),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Doctor Name',
                hint: 'Enter doctor\'s name',
                controller: _doctorController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Doctor name'),
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 20),
              _buildSpecialtySelector(),
              const SizedBox(height: 20),
              _buildDateTimeSelector(),
              const SizedBox(height: 20),
              _buildDurationSelector(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Location',
                hint: 'Hospital, clinic, or office name',
                controller: _locationController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Location'),
                prefixIcon: const Icon(Icons.location_on),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Address (Optional)',
                hint: 'Full address',
                controller: _addressController,
                prefixIcon: const Icon(Icons.place),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Contact Number (Optional)',
                hint: 'Clinic or doctor\'s phone number',
                controller: _contactController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description (Optional)',
                hint: 'Purpose of visit or additional details',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),
              const SizedBox(height: 20),
              _buildReminderSection(),
              const SizedBox(height: 20),
              _buildSymptomsSection(),
              const SizedBox(height: 20),
              _buildMedicationsSection(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Additional notes or preparation instructions',
                controller: _notesController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.notes),
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: isEditing ? 'Update Appointment' : 'Schedule Appointment',
                isLoading: _isLoading,
                onPressed: _saveAppointment,
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
          'Appointment Type',
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
          children: AppointmentType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type.color.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? type.color : AppColors.lightColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: isSelected ? type.color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? type.color
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

  Widget _buildSpecialtySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialty',
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
              value: _specialties.contains(_specialtyController.text)
                  ? _specialtyController.text
                  : _specialties.first,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  _specialtyController.text = value!;
                });
              },
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector() {
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectDate,
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
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _selectTime,
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
                        Icons.access_time,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _durations.map((duration) {
            final isSelected = _selectedDuration == duration;
            final minutes = duration.inMinutes;
            final displayText = minutes < 60
                ? '${minutes}m'
                : '${(minutes / 60).floor()}h${minutes % 60 > 0 ? ' ${minutes % 60}m' : ''}';

            return GestureDetector(
              onTap: () => setState(() => _selectedDuration = duration),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.lightColor,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reminder',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Switch(
              value: _isReminderSet,
              onChanged: (value) {
                setState(() {
                  _isReminderSet = value;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
        if (_isReminderSet) ...[
          const SizedBox(height: 12),
          const Text(
            'Remind me before:',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _reminderOptions.map((minutes) {
              final isSelected = _reminderMinutes == minutes;
              final displayText = _getReminderDisplayText(minutes);

              return GestureDetector(
                onTap: () => setState(() => _reminderMinutes = minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryColor
                          : AppColors.lightColor,
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondaryColor
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Symptoms to Discuss (Optional)',
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
            final isSelected = _selectedSymptoms.contains(symptom);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSymptoms.remove(symptom);
                  } else {
                    _selectedSymptoms.add(symptom);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.orange : AppColors.lightColor,
                  ),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.orange : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Current Medications (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_selectedMedications.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightColor),
            ),
            child: const Center(
              child: Text(
                'No medications added yet',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Column(
            children: _selectedMedications.asMap().entries.map((entry) {
              final index = entry.key;
              final medication = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medication,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeMedication(index),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _getReminderDisplayText(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '${hours}h';
    } else {
      final days = minutes ~/ 1440;
      return '${days}d';
    }
  }

  Future<void> _addMedication() async {
    final medication = await showDialog<String>(
      context: context,
      builder: (context) => _AddMedicationDialog(),
    );

    if (medication != null && medication.isNotEmpty) {
      setState(() {
        _selectedMedications.add(medication);
      });
    }
  }

  void _removeMedication(int index) {
    setState(() {
      _selectedMedications.removeAt(index);
    });
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final appointment = AppointmentModel(
        id:
            widget.appointment?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        doctorName: _doctorController.text.trim(),
        specialty: _specialtyController.text.isNotEmpty
            ? _specialtyController.text
            : _specialties.first,
        location: _locationController.text.trim(),
        dateTime: appointmentDateTime,
        duration: _selectedDuration,
        type: _selectedType,
        status: _selectedStatus,
        description: _descriptionController.text.trim(),
        notes: _notesController.text.trim(),
        isReminderSet: _isReminderSet,
        reminderMinutes: _reminderMinutes,
        contactNumber: _contactController.text.trim(),
        address: _addressController.text.trim(),
        symptoms: _selectedSymptoms,
        medications: _selectedMedications,
        createdAt: widget.appointment?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );

      if (widget.appointment != null) {
        await provider.updateAppointment(appointment);
      } else {
        await provider.addAppointment(appointment);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.appointment != null
                  ? 'Appointment updated successfully'
                  : 'Appointment scheduled successfully',
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

class _AddMedicationDialog extends StatefulWidget {
  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter medication name and dosage',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
