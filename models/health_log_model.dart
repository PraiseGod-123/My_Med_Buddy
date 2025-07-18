import 'package:flutter/material.dart';
import 'dart:convert';

class HealthLogModel {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final HealthLogType type;
  final Map<String, dynamic> metrics;
  final String? mood;
  final List<String> symptoms;
  final String? notes;

  HealthLogModel({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.metrics = const {},
    this.mood,
    this.symptoms = const [],
    this.notes,
  });

  HealthLogModel copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    HealthLogType? type,
    Map<String, dynamic>? metrics,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) {
    return HealthLogModel(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      metrics: metrics ?? this.metrics,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'type': type.toString(),
      'metrics': metrics,
      'mood': mood,
      'symptoms': symptoms,
      'notes': notes,
    };
  }

  factory HealthLogModel.fromJson(Map<String, dynamic> json) {
    return HealthLogModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      type: HealthLogType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => HealthLogType.general,
      ),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      mood: json['mood'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      notes: json['notes'],
    );
  }
}

enum HealthLogType { vitals, symptoms, mood, exercise, sleep, general }

extension HealthLogTypeExtension on HealthLogType {
  String get displayName {
    switch (this) {
      case HealthLogType.vitals:
        return 'Vitals';
      case HealthLogType.symptoms:
        return 'Symptoms';
      case HealthLogType.mood:
        return 'Mood';
      case HealthLogType.exercise:
        return 'Exercise';
      case HealthLogType.sleep:
        return 'Sleep';
      case HealthLogType.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthLogType.vitals:
        return Icons.favorite;
      case HealthLogType.symptoms:
        return Icons.healing;
      case HealthLogType.mood:
        return Icons.mood;
      case HealthLogType.exercise:
        return Icons.fitness_center;
      case HealthLogType.sleep:
        return Icons.bedtime;
      case HealthLogType.general:
        return Icons.note;
    }
  }
}
