import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _secureStorage = SecureStorageService();
  final _allergenController = TextEditingController();
  List<String> _allergens = [];

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    final saved = await _secureStorage.loadAllergens();
    setState(() => _allergens = saved);
  }

  Future<void> _saveAllergens() async {
    await _secureStorage.saveAllergens(_allergens);
  }

  void _addAllergen() {
    final allergen = _allergenController.text.trim();
    if (allergen.isNotEmpty && !_allergens.contains(allergen)) {
      setState(() {
        _allergens.add(allergen);
        _allergenController.clear();
      });
      _saveAllergens();
    }
  }

  void _deleteAllergen(String allergen) {
    setState(() => _allergens.remove(allergen));
    _saveAllergens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Allergy Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _allergenController,
            decoration: InputDecoration(
              hintText: "Enter allergen (e.g. penicillin)",
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addAllergen,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.deepPurple.withOpacity(0.05),
            ),
          ),
          const SizedBox(height: 20),
          if (_allergens.isNotEmpty)
            ..._allergens.map(
                  (a) => Card(
                child: ListTile(
                  title: Text(a),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAllergen(a),
                  ),
                ),
              ),
            )
          else
            const Text(
              "No allergens added yet.",
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
