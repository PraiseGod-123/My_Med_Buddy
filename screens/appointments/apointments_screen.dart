// lib/screens/appointments/appointments_screen.dart
// Simple version without complex provider dependencies

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointments_provider.dart';
import '../../core/constants/app_colors.dart';

import '../../models/appointment_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_spinner.dart';
import 'add_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'Appointments',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryColor),
            onPressed: _navigateToAddAppointment,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Today'),
            Tab(text: 'All'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<AppointmentsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingSpinner();
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingTab(provider),
              _buildTodayTab(provider),
              _buildAllTab(provider),
              _buildPastTab(provider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAppointment,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingTab(AppointmentsProvider provider) {
    final appointments = provider.upcomingAppointments;

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No upcoming appointments',
        'Schedule your next appointment',
        Icons.calendar_today,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildTodayTab(AppointmentsProvider provider) {
    final appointments = provider.todaysAppointments;

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No appointments today',
        'Enjoy your free day!',
        Icons.free_breakfast,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAllTab(AppointmentsProvider provider) {
    final appointments = provider.appointments;

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No appointments yet',
        'Start by scheduling your first appointment',
        Icons.calendar_month,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildPastTab(AppointmentsProvider provider) {
    final appointments = provider.pastAppointments;

    if (appointments.isEmpty) {
      return _buildEmptyState(
        'No past appointments',
        'Your appointment history will appear here',
        Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: appointment.status.color,
          child: Icon(appointment.type.icon, color: Colors.white, size: 20),
        ),
        title: Text(
          appointment.doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.specialty),
            const SizedBox(height: 4),
            Text(
              '${appointment.formattedDate} at ${appointment.formattedTime}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (appointment.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, appointment),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                dense: true,
              ),
            ),
            if (appointment.canCancel)
              const PopupMenuItem(
                value: 'cancel',
                child: ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red),
                  title: Text('Cancel'),
                  dense: true,
                ),
              ),
            if (appointment.canComplete)
              const PopupMenuItem(
                value: 'complete',
                child: ListTile(
                  leading: Icon(Icons.check, color: Colors.green),
                  title: Text('Complete'),
                  dense: true,
                ),
              ),
          ],
        ),
        onTap: () => _showAppointmentDetails(appointment),
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
              text: 'Schedule Appointment',
              onPressed: _navigateToAddAppointment,
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
                final provider = Provider.of<AppointmentsProvider>(
                  context,
                  listen: false,
                );
                provider.loadAppointments();
              },
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAppointmentScreen()),
    );
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appointment.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${appointment.doctorName}'),
            Text('Specialty: ${appointment.specialty}'),
            Text('Date: ${appointment.formattedDate}'),
            Text('Time: ${appointment.formattedTime}'),
            Text('Location: ${appointment.location}'),
            if (appointment.description.isNotEmpty)
              Text('Description: ${appointment.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, AppointmentModel appointment) {
    final provider = Provider.of<AppointmentsProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AddAppointmentScreen(appointment: appointment),
          ),
        );
        break;
      case 'cancel':
        _showCancelDialog(appointment);
        break;
      case 'complete':
        provider.completeAppointment(appointment.id, 'Completed');
        break;
    }
  }

  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<AppointmentsProvider>(
                context,
                listen: false,
              );
              provider.cancelAppointment(appointment.id, 'Cancelled by user');
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
