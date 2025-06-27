import 'package:flutter/material.dart';

class ReminderModel {
  final String medicineName;
  final String? dosage;
  final String? frequency;
  final String? duration;
  final int timesPerDay;
  List<TimeOfDay> times;

  ReminderModel({
    required this.medicineName,
    this.dosage,
    this.frequency,
    this.duration,
    required this.timesPerDay,
    List<TimeOfDay>? times,
  }) : times = times ?? [];

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'dosage': dosage,
        'frequency': frequency,
        'duration': duration,
        'timesPerDay': timesPerDay,
        'times': times.map((t) => '${t.hour}:${t.minute}').toList(),
      };

  // Construct from JSON
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    final timeList = (json['times'] as List<dynamic>).map((timeString) {
      final parts = (timeString as String).split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }).toList();

    return ReminderModel(
      medicineName: json['medicineName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      timesPerDay: json['timesPerDay'] ?? timeList.length,
      times: timeList,
    );
  }

  @override
  String toString() {
    final formattedTimes = times
        .map((t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}')
        .join(', ');
    return '''
Name: $medicineName
Dosage: ${dosage ?? 'N/A'}
Frequency: ${frequency ?? 'N/A'}
Duration: ${duration ?? 'N/A'}
Times per day: $timesPerDay
Times: $formattedTimes
''';
  }
}
