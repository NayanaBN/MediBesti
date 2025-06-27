import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAllergens(List<String> allergens) async {
    await _storage.write(key: 'allergens', value: allergens.join(','));
  }

  Future<List<String>> loadAllergens() async {
    final data = await _storage.read(key: 'allergens');
    if (data == null || data.isEmpty) return [];
    return data.split(',');
  }

  Future<void> clearAllergens() async {
    await _storage.delete(key: 'allergens');
  }
}
