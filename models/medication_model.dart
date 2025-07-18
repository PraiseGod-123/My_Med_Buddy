import 'dart:convert';

class MedicationModel {
  final String id;
  final String name;
  final String dosage;
  final String frequency; // "Once daily", "Twice daily", etc.
  final List<String> times; // ["08:00", "20:00"]
  final String instructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String color; // For UI theming
  final List<MedicationLog> logs;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.instructions,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.color = 'primary',
    this.logs = const [],
  });

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? color,
    List<MedicationLog>? logs,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      color: color ?? this.color,
      logs: logs ?? this.logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'color': color,
      'logs': logs.map((log) => log.toJson()).toList(),
    };
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      times: List<String>.from(json['times']),
      instructions: json['instructions'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      color: json['color'] ?? 'primary',
      logs:
          (json['logs'] as List?)
              ?.map((log) => MedicationLog.fromJson(log))
              .toList() ??
          [],
    );
  }
}

class MedicationLog {
  final String id;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool isTaken;
  final bool isSkipped;
  final String? notes;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
    this.isSkipped = false,
    this.notes,
  });

  MedicationLog copyWith({
    String? id,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    bool? isTaken,
    bool? isSkipped,
    String? notes,
  }) {
    return MedicationLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      isTaken: isTaken ?? this.isTaken,
      isSkipped: isSkipped ?? this.isSkipped,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'isTaken': isTaken,
      'isSkipped': isSkipped,
      'notes': notes,
    };
  }

  factory MedicationLog.fromJson(Map<String, dynamic> json) {
    return MedicationLog(
      id: json['id'],
      medicationId: json['medicationId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'])
          : null,
      isTaken: json['isTaken'] ?? false,
      isSkipped: json['isSkipped'] ?? false,
      notes: json['notes'],
    );
  }
}
