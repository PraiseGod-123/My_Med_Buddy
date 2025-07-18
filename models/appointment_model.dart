// lib/models/appointment_model.dart
import 'package:flutter/material.dart';
import 'dart:convert';

class AppointmentModel {
  final String id;
  final String title;
  final String doctorName;
  final String specialty;
  final String location;
  final DateTime dateTime;
  final Duration duration;
  final AppointmentType type;
  final AppointmentStatus status;
  final String description;
  final String notes;
  final bool isReminderSet;
  final int reminderMinutes;
  final String contactNumber;
  final String address;
  final Map<String, dynamic> metadata;
  final List<String> symptoms;
  final List<String> medications;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.specialty,
    required this.location,
    required this.dateTime,
    this.duration = const Duration(minutes: 30),
    this.type = AppointmentType.checkup,
    this.status = AppointmentStatus.scheduled,
    this.description = '',
    this.notes = '',
    this.isReminderSet = true,
    this.reminderMinutes = 30,
    this.contactNumber = '',
    this.address = '',
    this.metadata = const {},
    this.symptoms = const [],
    this.medications = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  AppointmentModel copyWith({
    String? id,
    String? title,
    String? doctorName,
    String? specialty,
    String? location,
    DateTime? dateTime,
    Duration? duration,
    AppointmentType? type,
    AppointmentStatus? status,
    String? description,
    String? notes,
    bool? isReminderSet,
    int? reminderMinutes,
    String? contactNumber,
    String? address,
    Map<String, dynamic>? metadata,
    List<String>? symptoms,
    List<String>? medications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      isReminderSet: isReminderSet ?? this.isReminderSet,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      metadata: metadata ?? this.metadata,
      symptoms: symptoms ?? this.symptoms,
      medications: medications ?? this.medications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'doctorName': doctorName,
      'specialty': specialty,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration.inMinutes,
      'type': type.toString(),
      'status': status.toString(),
      'description': description,
      'notes': notes,
      'isReminderSet': isReminderSet,
      'reminderMinutes': reminderMinutes,
      'contactNumber': contactNumber,
      'address': address,
      'metadata': metadata,
      'symptoms': symptoms,
      'medications': medications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      title: json['title'],
      doctorName: json['doctorName'],
      specialty: json['specialty'],
      location: json['location'],
      dateTime: DateTime.parse(json['dateTime']),
      duration: Duration(minutes: json['duration'] ?? 30),
      type: AppointmentType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AppointmentType.checkup,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      description: json['description'] ?? '',
      notes: json['notes'] ?? '',
      isReminderSet: json['isReminderSet'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 30,
      contactNumber: json['contactNumber'] ?? '',
      address: json['address'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      symptoms: List<String>.from(json['symptoms'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper methods
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isPast => dateTime.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  DateTime get endTime => dateTime.add(duration);

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (appointmentDate == today) {
      return 'Today';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (appointmentDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String get formattedTime {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String get formattedDateTime => '$formattedDate at $formattedTime';

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Duration get timeUntilAppointment => dateTime.difference(DateTime.now());

  String get reminderTimeDisplay {
    if (reminderMinutes < 60) {
      return '$reminderMinutes minutes before';
    } else if (reminderMinutes < 1440) {
      final hours = reminderMinutes ~/ 60;
      final minutes = reminderMinutes % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''} before';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''} before';
      }
    } else {
      final days = reminderMinutes ~/ 1440;
      return '$days day${days > 1 ? 's' : ''} before';
    }
  }

  bool get canCancel => status == AppointmentStatus.scheduled && isUpcoming;
  bool get canReschedule => status == AppointmentStatus.scheduled && isUpcoming;
  bool get canComplete => status == AppointmentStatus.scheduled && !isUpcoming;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, title: $title, doctorName: $doctorName, dateTime: $dateTime, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel &&
        other.id == id &&
        other.title == title &&
        other.doctorName == doctorName &&
        other.dateTime == dateTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        doctorName.hashCode ^
        dateTime.hashCode;
  }
}

enum AppointmentType {
  checkup,
  consultation,
  followUp,
  emergency,
  surgery,
  diagnostic,
  vaccination,
  therapy,
  dentistry,
  vision,
  specialist,
  other,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
  missed,
  waitingList,
}

// Extensions for better enum handling
extension AppointmentTypeExtension on AppointmentType {
  String get displayName {
    switch (this) {
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.surgery:
        return 'Surgery';
      case AppointmentType.diagnostic:
        return 'Diagnostic';
      case AppointmentType.vaccination:
        return 'Vaccination';
      case AppointmentType.therapy:
        return 'Therapy';
      case AppointmentType.dentistry:
        return 'Dentistry';
      case AppointmentType.vision:
        return 'Vision';
      case AppointmentType.specialist:
        return 'Specialist';
      case AppointmentType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentType.checkup:
        return Icons.medical_services;
      case AppointmentType.consultation:
        return Icons.chat;
      case AppointmentType.followUp:
        return Icons.schedule;
      case AppointmentType.emergency:
        return Icons.local_hospital;
      case AppointmentType.surgery:
        return Icons.local_hospital;
      case AppointmentType.diagnostic:
        return Icons.biotech;
      case AppointmentType.vaccination:
        return Icons.medical_services;
      case AppointmentType.therapy:
        return Icons.healing;
      case AppointmentType.dentistry:
        return Icons.medical_services;
      case AppointmentType.vision:
        return Icons.visibility;
      case AppointmentType.specialist:
        return Icons.person;
      case AppointmentType.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case AppointmentType.checkup:
        return Colors.blue;
      case AppointmentType.consultation:
        return Colors.green;
      case AppointmentType.followUp:
        return Colors.orange;
      case AppointmentType.emergency:
        return Colors.red;
      case AppointmentType.surgery:
        return Colors.purple;
      case AppointmentType.diagnostic:
        return Colors.teal;
      case AppointmentType.vaccination:
        return Colors.indigo;
      case AppointmentType.therapy:
        return Colors.pink;
      case AppointmentType.dentistry:
        return Colors.cyan;
      case AppointmentType.vision:
        return Colors.amber;
      case AppointmentType.specialist:
        return Colors.brown;
      case AppointmentType.other:
        return Colors.grey;
    }
  }
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rescheduled:
        return 'Rescheduled';
      case AppointmentStatus.missed:
        return 'Missed';
      case AppointmentStatus.waitingList:
        return 'Waiting List';
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.inProgress:
        return Icons.access_time;
      case AppointmentStatus.completed:
        return Icons.check_circle_outline;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.rescheduled:
        return Icons.update;
      case AppointmentStatus.missed:
        return Icons.error;
      case AppointmentStatus.waitingList:
        return Icons.hourglass_empty;
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rescheduled:
        return Colors.purple;
      case AppointmentStatus.missed:
        return Colors.red;
      case AppointmentStatus.waitingList:
        return Colors.grey;
    }
  }

  bool get isActive =>
      this == AppointmentStatus.scheduled ||
      this == AppointmentStatus.confirmed ||
      this == AppointmentStatus.inProgress;
}

// Utility class for appointment operations
class AppointmentUtils {
  static List<AppointmentModel> sortByDateTime(
    List<AppointmentModel> appointments,
  ) {
    final sorted = List<AppointmentModel>.from(appointments);
    sorted.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted;
  }

  static List<AppointmentModel> filterByStatus(
    List<AppointmentModel> appointments,
    AppointmentStatus status,
  ) {
    return appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  static List<AppointmentModel> filterByType(
    List<AppointmentModel> appointments,
    AppointmentType type,
  ) {
    return appointments
        .where((appointment) => appointment.type == type)
        .toList();
  }

  static List<AppointmentModel> filterByDateRange(
    List<AppointmentModel> appointments,
    DateTime startDate,
    DateTime endDate,
  ) {
    return appointments.where((appointment) {
      return appointment.dateTime.isAfter(startDate) &&
          appointment.dateTime.isBefore(endDate);
    }).toList();
  }

  static List<AppointmentModel> getUpcomingAppointments(
    List<AppointmentModel> appointments,
  ) {
    final now = DateTime.now();
    return appointments
        .where((appointment) => appointment.dateTime.isAfter(now))
        .toList();
  }

  static List<AppointmentModel> getTodaysAppointments(
    List<AppointmentModel> appointments,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return appointments.where((appointment) {
      return appointment.dateTime.isAfter(today) &&
          appointment.dateTime.isBefore(tomorrow);
    }).toList();
  }

  static Map<String, List<AppointmentModel>> groupByDoctor(
    List<AppointmentModel> appointments,
  ) {
    final Map<String, List<AppointmentModel>> grouped = {};

    for (final appointment in appointments) {
      if (!grouped.containsKey(appointment.doctorName)) {
        grouped[appointment.doctorName] = [];
      }
      grouped[appointment.doctorName]!.add(appointment);
    }

    return grouped;
  }

  static Map<String, List<AppointmentModel>> groupBySpecialty(
    List<AppointmentModel> appointments,
  ) {
    final Map<String, List<AppointmentModel>> grouped = {};

    for (final appointment in appointments) {
      if (!grouped.containsKey(appointment.specialty)) {
        grouped[appointment.specialty] = [];
      }
      grouped[appointment.specialty]!.add(appointment);
    }

    return grouped;
  }

  static bool hasConflict(
    AppointmentModel appointment,
    List<AppointmentModel> existingAppointments,
  ) {
    for (final existing in existingAppointments) {
      if (existing.id == appointment.id) continue;

      final appointmentStart = appointment.dateTime;
      final appointmentEnd = appointment.endTime;
      final existingStart = existing.dateTime;
      final existingEnd = existing.endTime;

      // Check for overlap
      if (appointmentStart.isBefore(existingEnd) &&
          appointmentEnd.isAfter(existingStart)) {
        return true;
      }
    }
    return false;
  }

  static Duration getTimeBetweenAppointments(
    AppointmentModel first,
    AppointmentModel second,
  ) {
    final firstEnd = first.endTime;
    final secondStart = second.dateTime;

    if (firstEnd.isBefore(secondStart)) {
      return secondStart.difference(firstEnd);
    } else {
      return Duration.zero;
    }
  }
}
