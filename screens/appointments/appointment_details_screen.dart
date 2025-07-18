// lib/screens/appointments/appointment_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/appointment_model.dart';
import '../../providers/appointments_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'add_appointment_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailsScreen({Key? key, required this.appointment})
    : super(key: key);

  @override
  State<AppointmentDetailsScreen> createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppointmentModel _currentAppointment;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentAppointment = widget.appointment;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_currentAppointment.status.isActive)
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                if (_currentAppointment.canReschedule)
                  const PopupMenuItem(
                    value: 'reschedule',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, size: 20),
                        SizedBox(width: 12),
                        Text('Reschedule'),
                      ],
                    ),
                  ),
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
                if (_currentAppointment.canCancel)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 20,
                          color: AppColors.errorColor,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Cancel',
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
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildAppointmentHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDetailsTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildAppointmentHeader() {
    final isOverdue =
        _currentAppointment.dateTime.isBefore(DateTime.now()) &&
        _currentAppointment.status == AppointmentStatus.scheduled;
    final isDueSoon =
        !isOverdue &&
        _currentAppointment.dateTime.isBefore(
          DateTime.now().add(const Duration(hours: 2)),
        ) &&
        _currentAppointment.status.isActive;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentAppointment.type.color,
            _currentAppointment.type.color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _currentAppointment.type.color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _currentAppointment.type.icon,
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
                      _currentAppointment.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentAppointment.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentAppointment.status.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo(
                  Icons.schedule,
                  'Date & Time',
                  _currentAppointment.formattedDateTime,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildHeaderInfo(
                  Icons.access_time,
                  'Duration',
                  _currentAppointment.formattedDuration,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildHeaderInfo(
                  Icons.location_on,
                  'Location',
                  _currentAppointment.location,
                ),
              ),
            ],
          ),
          if (isOverdue || isDueSoon) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOverdue ? Colors.red : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning : Icons.access_time,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOverdue
                        ? 'This appointment is overdue'
                        : 'Appointment due soon - ${_getTimeUntil()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Appointment Information', [
            _buildInfoRow('Type', _currentAppointment.type.displayName),
            _buildInfoRow('Specialty', _currentAppointment.specialty),
            _buildInfoRow('Status', _currentAppointment.status.displayName),
            if (_currentAppointment.description.isNotEmpty)
              _buildInfoRow('Description', _currentAppointment.description),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Location & Contact', [
            _buildInfoRow('Location', _currentAppointment.location),
            if (_currentAppointment.address.isNotEmpty)
              _buildInfoRow(
                'Address',
                _currentAppointment.address,
                action: () => _openMaps(_currentAppointment.address),
              ),
            if (_currentAppointment.contactNumber.isNotEmpty)
              _buildInfoRow(
                'Contact',
                _currentAppointment.contactNumber,
                action: () => _makePhoneCall(_currentAppointment.contactNumber),
              ),
          ]),
          const SizedBox(height: 16),
          if (_currentAppointment.isReminderSet)
            _buildInfoCard('Reminder Settings', [
              _buildInfoRow('Reminder', 'Enabled'),
              _buildInfoRow(
                'Remind Before',
                _currentAppointment.reminderTimeDisplay,
              ),
            ]),
          const SizedBox(height: 16),
          if (_currentAppointment.symptoms.isNotEmpty) _buildSymptomsCard(),
          const SizedBox(height: 16),
          if (_currentAppointment.medications.isNotEmpty)
            _buildMedicationsCard(),
          const SizedBox(height: 16),
          _buildTimestampsCard(),
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
          _buildInfoCard('Complete Details', [
            _buildInfoRow('Appointment ID', _currentAppointment.id),
            _buildInfoRow('Title', _currentAppointment.title),
            _buildInfoRow('Doctor', _currentAppointment.doctorName),
            _buildInfoRow('Specialty', _currentAppointment.specialty),
            _buildInfoRow('Type', _currentAppointment.type.displayName),
            _buildInfoRow('Status', _currentAppointment.status.displayName),
            _buildInfoRow(
              'Date',
              DateFormat(
                'EEEE, MMMM dd, yyyy',
              ).format(_currentAppointment.dateTime),
            ),
            _buildInfoRow(
              'Time',
              DateFormat('h:mm a').format(_currentAppointment.dateTime),
            ),
            _buildInfoRow('Duration', _currentAppointment.formattedDuration),
            _buildInfoRow(
              'End Time',
              DateFormat('h:mm a').format(_currentAppointment.endTime),
            ),
            _buildInfoRow('Location', _currentAppointment.location),
            if (_currentAppointment.address.isNotEmpty)
              _buildInfoRow('Full Address', _currentAppointment.address),
            if (_currentAppointment.contactNumber.isNotEmpty)
              _buildInfoRow(
                'Contact Number',
                _currentAppointment.contactNumber,
              ),
            if (_currentAppointment.description.isNotEmpty)
              _buildInfoRow('Description', _currentAppointment.description),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Metadata', [
            _buildInfoRow(
              'Created',
              DateFormat(
                'MMM dd, yyyy • h:mm a',
              ).format(_currentAppointment.createdAt),
            ),
            _buildInfoRow(
              'Last Updated',
              DateFormat(
                'MMM dd, yyyy • h:mm a',
              ).format(_currentAppointment.updatedAt),
            ),
            _buildInfoRow(
              'Reminder Enabled',
              _currentAppointment.isReminderSet ? 'Yes' : 'No',
            ),
            if (_currentAppointment.isReminderSet)
              _buildInfoRow(
                'Reminder Time',
                _currentAppointment.reminderTimeDisplay,
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Appointment Notes', [
            if (_currentAppointment.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentAppointment.notes,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.note_add,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No notes added yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add notes about this appointment',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ]),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Add/Edit Notes',
            isOutlined: true,
            onPressed: _editNotes,
            icon: Icons.edit_note,
          ),
          const SizedBox(height: 16),
          if (_currentAppointment.symptoms.isNotEmpty ||
              _currentAppointment.medications.isNotEmpty)
            _buildInfoCard('Preparation Checklist', [
              if (_currentAppointment.symptoms.isNotEmpty)
                _buildChecklistItem(
                  'Symptoms to discuss',
                  _currentAppointment.symptoms.join(', '),
                ),
              if (_currentAppointment.medications.isNotEmpty)
                _buildChecklistItem(
                  'Current medications',
                  _currentAppointment.medications.join(', '),
                ),
              _buildChecklistItem('Bring insurance card', ''),
              _buildChecklistItem('Bring ID', ''),
              _buildChecklistItem('Arrive 15 minutes early', ''),
            ]),
        ],
      ),
    );
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
            offset: const Offset(0, 5),
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

  Widget _buildInfoRow(String label, String value, {VoidCallback? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            child: GestureDetector(
              onTap: action,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: action != null
                      ? AppColors.primaryColor
                      : AppColors.textPrimary,
                  decoration: action != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: action,
              child: const Icon(
                Icons.open_in_new,
                size: 16,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return _buildInfoCard('Symptoms to Discuss', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _currentAppointment.symptoms.map((symptom) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Text(
              symptom,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.orange,
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildMedicationsCard() {
    return _buildInfoCard('Current Medications', [
      Column(
        children: _currentAppointment.medications.map((medication) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
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
              ],
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildTimestampsCard() {
    return _buildInfoCard('Record Information', [
      _buildInfoRow(
        'Created',
        DateFormat(
          'MMM dd, yyyy • h:mm a',
        ).format(_currentAppointment.createdAt),
      ),
      _buildInfoRow(
        'Last Updated',
        DateFormat(
          'MMM dd, yyyy • h:mm a',
        ).format(_currentAppointment.updatedAt),
      ),
      _buildInfoRow('Appointment ID', _currentAppointment.id),
    ]);
  }

  Widget _buildChecklistItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    if (!_currentAppointment.status.isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentAppointment.canCancel)
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  isOutlined: true,
                  onPressed: _cancelAppointment,
                ),
              ),
            if (_currentAppointment.canCancel &&
                (_currentAppointment.canReschedule ||
                    _currentAppointment.canComplete))
              const SizedBox(width: 12),
            if (_currentAppointment.canReschedule)
              Expanded(
                child: CustomButton(
                  text: 'Reschedule',
                  isOutlined: true,
                  onPressed: _rescheduleAppointment,
                ),
              ),
            if (_currentAppointment.canReschedule &&
                _currentAppointment.canComplete)
              const SizedBox(width: 12),
            if (_currentAppointment.canComplete)
              Expanded(
                child: CustomButton(
                  text: 'Complete',
                  onPressed: _completeAppointment,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeUntil() {
    final now = DateTime.now();
    final difference = _currentAppointment.dateTime.difference(now);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'reschedule':
        _rescheduleAppointment();
        break;
      case 'edit':
        _editAppointment();
        break;
      case 'duplicate':
        _duplicateAppointment();
        break;
      case 'cancel':
        _cancelAppointment();
        break;
    }
  }

  Future<void> _editAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddAppointmentScreen(appointment: _currentAppointment),
      ),
    );

    if (result == true) {
      // Refresh appointment data
      _refreshAppointment();
    }
  }

  Future<void> _duplicateAppointment() async {
    final duplicatedAppointment = _currentAppointment.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${_currentAppointment.title} (Copy)',
      dateTime: _currentAppointment.dateTime.add(const Duration(days: 7)),
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddAppointmentScreen(appointment: duplicatedAppointment),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _CancelAppointmentDialog(),
    );

    if (reason != null) {
      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );
      await provider.cancelAppointment(_currentAppointment.id, reason);
      _refreshAppointment();
    }
  }

  Future<void> _rescheduleAppointment() async {
    final newDateTime = await _showRescheduleDialog();
    if (newDateTime != null) {
      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );
      await provider.rescheduleAppointment(_currentAppointment.id, newDateTime);
      _refreshAppointment();
    }
  }

  Future<void> _completeAppointment() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) =>
          _CompleteAppointmentDialog(currentNotes: _currentAppointment.notes),
    );

    if (notes != null) {
      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );
      await provider.completeAppointment(_currentAppointment.id, notes);
      _refreshAppointment();
    }
  }

  Future<void> _editNotes() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) =>
          _EditNotesDialog(currentNotes: _currentAppointment.notes),
    );

    if (notes != null) {
      final updatedAppointment = _currentAppointment.copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final provider = Provider.of<AppointmentsProvider>(
        context,
        listen: false,
      );
      await provider.updateAppointment(updatedAppointment);
      _refreshAppointment();
    }
  }

  Future<DateTime?> _showRescheduleDialog() async {
    DateTime? newDate;
    TimeOfDay? newTime;

    newDate = await showDatePicker(
      context: context,
      initialDate: _currentAppointment.dateTime.add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate == null) return null;

    newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_currentAppointment.dateTime),
    );

    if (newTime == null) return null;

    return DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );
  }

  void _refreshAppointment() {
    final provider = Provider.of<AppointmentsProvider>(context, listen: false);
    final updatedAppointment = provider.allAppointments.firstWhere(
      (app) => app.id == _currentAppointment.id,
      orElse: () => _currentAppointment,
    );

    setState(() {
      _currentAppointment = updatedAppointment;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Copy phone number to clipboard and show options
    await Clipboard.setData(ClipboardData(text: phoneNumber));

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Phone: $phoneNumber'),
              const SizedBox(height: 8),
              const Text('Phone number copied to clipboard.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openMaps(String address) async {
    // Copy address to clipboard and show options
    await Clipboard.setData(ClipboardData(text: address));

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Address:'),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              const Text(
                'Address copied to clipboard. You can paste it in your maps app.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}

// Dialog for canceling appointment
class _CancelAppointmentDialog extends StatefulWidget {
  @override
  State<_CancelAppointmentDialog> createState() =>
      _CancelAppointmentDialogState();
}

class _CancelAppointmentDialogState extends State<_CancelAppointmentDialog> {
  final _controller = TextEditingController();
  String? _selectedReason;

  final List<String> _cancelReasons = [
    'Personal emergency',
    'Feeling better',
    'Scheduling conflict',
    'Doctor unavailable',
    'Transportation issues',
    'Insurance issues',
    'Other',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please select a reason for cancellation:'),
            const SizedBox(height: 16),
            ...(_cancelReasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }).toList()),
            const SizedBox(height: 16),
            const Text('Additional details (optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter additional details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedReason != null
              ? () {
                  final reason = _selectedReason!;
                  final details = _controller.text.trim();
                  final fullReason = details.isNotEmpty
                      ? '$reason: $details'
                      : reason;
                  Navigator.pop(context, fullReason);
                }
              : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
          child: const Text('Cancel Appointment'),
        ),
      ],
    );
  }
}

// Dialog for completing appointment
class _CompleteAppointmentDialog extends StatefulWidget {
  final String currentNotes;

  const _CompleteAppointmentDialog({required this.currentNotes});

  @override
  State<_CompleteAppointmentDialog> createState() =>
      _CompleteAppointmentDialogState();
}

class _CompleteAppointmentDialogState
    extends State<_CompleteAppointmentDialog> {
  final _notesController = TextEditingController();
  final _prescriptionsController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.currentNotes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _prescriptionsController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Appointment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add notes from your appointment:'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Appointment summary, diagnosis, etc.',
                border: OutlineInputBorder(),
                labelText: 'Notes',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prescriptionsController,
              decoration: const InputDecoration(
                hintText: 'New prescriptions or medication changes',
                border: OutlineInputBorder(),
                labelText: 'Prescriptions (Optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _followUpController,
              decoration: const InputDecoration(
                hintText: 'Next appointment date, recommendations, etc.',
                border: OutlineInputBorder(),
                labelText: 'Follow-up Instructions (Optional)',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final notes = _notesController.text.trim();
            final prescriptions = _prescriptionsController.text.trim();
            final followUp = _followUpController.text.trim();

            String fullNotes = notes;
            if (prescriptions.isNotEmpty) {
              fullNotes += '\n\nPrescriptions:\n$prescriptions';
            }
            if (followUp.isNotEmpty) {
              fullNotes += '\n\nFollow-up:\n$followUp';
            }

            Navigator.pop(context, fullNotes);
          },
          child: const Text('Complete'),
        ),
      ],
    );
  }
}

// Dialog for editing notes
class _EditNotesDialog extends StatefulWidget {
  final String currentNotes;

  const _EditNotesDialog({required this.currentNotes});

  @override
  State<_EditNotesDialog> createState() => _EditNotesDialogState();
}

class _EditNotesDialogState extends State<_EditNotesDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentNotes;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Notes'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Add your notes here...',
          border: OutlineInputBorder(),
        ),
        maxLines: 8,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
