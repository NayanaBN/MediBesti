import 'package:shared_preferences/shared_preferences.dart';
import '../models/allergy_model.dart';
import 'dart:convert';

class AllergyService {
  final String _key = 'user_allergies';

  Future<void> saveAllergies(List<Allergy> allergies) async {
    final prefs = await SharedPreferences.getInstance();
    final list = allergies.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  Future<List<Allergy>> loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => Allergy.fromJson(jsonDecode(e))).toList();
  }

  Future<void> clearAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
