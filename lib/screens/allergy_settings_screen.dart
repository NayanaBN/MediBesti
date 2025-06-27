import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergySettingsScreen extends StatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  State<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends State<AllergySettingsScreen> {
  List<String> _allergens = [];
  final TextEditingController _controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allergens = prefs.getStringList('allergens') ?? [];
    });
  }

  Future<void> _addAllergen(String allergen) async {
    if (allergen.trim().isEmpty) return;
    setState(() {
      _allergens.add(allergen.trim());
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergens', _allergens);
    _controller.clear();
  }

  Future<void> _removeAllergen(int index) async {
    setState(() {
      _allergens.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergens', _allergens);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Allergy Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Add Allergen",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addAllergen(_controller.text),
                ),
              ),
              onSubmitted: _addAllergen,
            ),
            const SizedBox(height: 20),
            const Text("Known Allergens", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: _allergens.isEmpty
                  ? const Text("No allergens added.")
                  : ListView.builder(
                itemCount: _allergens.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_allergens[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeAllergen(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
