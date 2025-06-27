import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class HealthTipService {
  static const _tipKey = 'daily_health_tip';
  static const _dateKey = 'tip_date';

  final List<String> _tips = [
    "Drink at least 8 glasses of water a day.",
    "Get 7–9 hours of quality sleep every night.",
    "Take a short walk after meals to improve digestion.",
    "Eat more fruits and vegetables.",
    "Take deep breaths to reduce stress.",
    "Limit your screen time before bed.",
    "Don’t skip breakfast – it fuels your body for the day.",
    "Practice mindful eating to avoid overeating.",
    "Maintain a regular workout schedule.",
    "Wash your hands before meals to prevent infections.",
  ];

  Future<String> getDailyTip() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final savedDate = prefs.getString(_dateKey);
    String tip = prefs.getString(_tipKey) ?? "";

    if (savedDate != today || tip.isEmpty) {
      // New day → pick a new tip
      final random = Random();
      tip = _tips[random.nextInt(_tips.length)];
      await prefs.setString(_tipKey, tip);
      await prefs.setString(_dateKey, today);
    }

    return tip;
  }
}
