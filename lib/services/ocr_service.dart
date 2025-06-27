import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/reminder_model.dart';

class OCRService {
  final textRecognizer = TextRecognizer();

  Future<String> extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  List<String> extractMedicines(String fullText) {
    final lines = fullText.split('\n');
    final List<String> medicineLines = [];

    for (final line in lines) {
      final lowerLine = line.toLowerCase().trim();

      if (lowerLine.length < 3 ||
          lowerLine.contains(RegExp(
              r'(patient|name|age|sex|dr\.|date|address|phone|review|refill|diagnosis|take|before|after)'))) {
        continue;
      }

      if (line.contains(RegExp(
          r'(mg|ml|mcg|tab|cap|capsule|tablet|syrup|inj|injection|drops|cream)',
          caseSensitive: false))) {
        medicineLines.add(line.trim());
        continue;
      }

      if (line.trim().length < 40 && RegExp(r'^[A-Z][a-z]+').hasMatch(line)) {
        medicineLines.add(line.trim());
      }
    }

    return medicineLines;
  }

  List<ReminderModel> generateReminders(String fullText) {
    final lines = extractMedicines(fullText);
    final List<ReminderModel> reminders = [];

    for (final line in lines) {
      final parts = line.split(RegExp(r'\s+'));

      final name = parts.isNotEmpty ? parts.first : 'Unknown';
      final dosage = parts.firstWhere(
        (part) => RegExp(r'\d+(mg|ml|mcg|tab|tablet|cap|capsule|syrup|drops)',
                caseSensitive: false)
            .hasMatch(part),
        orElse: () => 'Unknown',
      );

      reminders.add(ReminderModel(
        medicineName: name,
        dosage: dosage,
        timesPerDay: 1, // Can be updated later based on frequency parsing
      ));
    }

    return reminders;
  }

  void dispose() {
    textRecognizer.close();
  }
}
