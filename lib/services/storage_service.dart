import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const _remindersKey = 'reminders';
  static const _allergensKey = 'user_allergens';

  // Save list of reminders
  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reminders.map((r) => r.toJson()).toList();
    await prefs.setString(_remindersKey, jsonEncode(jsonList));
  }

  // Load saved reminders
  Future<List<ReminderModel>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_remindersKey);
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      return decoded.map((item) => ReminderModel.fromJson(item)).toList();
    }
    return [];
  }

  // Clear all reminders
  Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remindersKey);
  }

  // Save list of allergens
  Future<void> saveAllergens(List<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_allergensKey, allergens);
  }

  // Load saved allergens
  Future<List<String>> loadAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_allergensKey) ?? [];
  }

  // Clear all allergens
  Future<void> clearAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_allergensKey);
  }
}
