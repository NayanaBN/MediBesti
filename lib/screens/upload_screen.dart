import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medibesti/screens/chat_screen.dart';
import '../services/image_storage_service.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';
import '../services/ocr_service.dart';
import '../services/storage_service.dart';
import '../services/health_tip_service.dart';
import '../screens/prescription_gallery_screen.dart';
import '../screens/doctor_connect_screen.dart';
import '../services/secure_storage_service.dart';
import '../screens/settings_screen.dart';
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _dailyTip;

  final OCRService _ocrService = OCRService();
  final StorageService _storageService = StorageService();
  final SecureStorageService _secureStorage = SecureStorageService();
  final NotificationService _notificationService = NotificationService();
  List<ReminderModel> _reminders = [];
  List<String> _userAllergens = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadSavedReminders();
    _loadDailyTip();
    _loadSecureAllergens(); // Corrected call
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.init();
  }

  Future<void> _loadSavedReminders() async {
    final saved = await _storageService.loadReminders();
    setState(() {
      _reminders = saved;
    });
  }

  Future<void> _loadDailyTip() async {
    final tip = await HealthTipService().getDailyTip();
    setState(() {
      _dailyTip = tip;
    });
  }

  Future<void> _loadSecureAllergens() async {
    final allergens = await _secureStorage.loadAllergens();
    setState(() {
      _userAllergens = allergens;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    final ImageStorageService _imageStorageService = ImageStorageService();

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final savedImagePath = await _imageStorageService.saveImage(imageFile);
      debugPrint('Saved image at: $savedImagePath');

      setState(() {
        _selectedImage = imageFile;
        _isLoading = true;
        _reminders = [];
      });

      try {
        String rawText = await _ocrService.extractTextFromImage(imageFile);
        List<ReminderModel> reminders = _ocrService.generateReminders(rawText);

        // Allergy Detection
        final matchedAllergens = reminders
            .where((r) =>
            _userAllergens.any((a) =>
                r.medicineName.toLowerCase().contains(a.toLowerCase())))
            .map((r) => r.medicineName)
            .toSet()
            .toList();

        if (matchedAllergens.isNotEmpty) {
          showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  title: const Text("⚠️ Allergy Warning"),
                  content: Text(
                      "The following medicines may contain allergens:\n\n${matchedAllergens
                          .join(", ")}"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }

        setState(() {
          _reminders = reminders;
        });

        await _storageService.saveReminders(_reminders);
        await _notificationService.scheduleReminders(_reminders);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract text: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addManualMedicine() {
    String name = '',
        dosage = '',
        frequency = '',
        duration = '';
    List<TimeOfDay> times = [];

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setDialogState) =>
                AlertDialog(
                  title: const Text("Add Medicine"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Medicine Name'),
                          onChanged: (val) => name = val,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Dosage'),
                          onChanged: (val) => dosage = val,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Frequency'),
                          onChanged: (val) => frequency = val,
                        ),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Duration'),
                          onChanged: (val) => duration = val,
                        ),
                        const SizedBox(height: 10),
                        const Text("Reminder Times:"),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...times.map((t) =>
                                Chip(
                                  label: Text(t.format(context)),
                                  onDeleted: () {
                                    setDialogState(() {
                                      times.remove(t);
                                    });
                                  },
                                )),
                            ActionChip(
                              label: const Text("Add Time"),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    times.add(picked);
                                  });
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (name.isNotEmpty) {
                          final reminder = ReminderModel(
                            medicineName: name,
                            dosage: dosage,
                            frequency: frequency,
                            duration: duration,
                            timesPerDay: times.length,
                            times: times,
                          );

                          setState(() => _reminders.add(reminder));
                          await _storageService.saveReminders(_reminders);
                          await _notificationService.scheduleReminders(
                              _reminders);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    )
                  ],
                ),
          ),
    );
  }

  void _editReminder(int index) async {
    final reminder = _reminders[index];
    final nameController = TextEditingController(text: reminder.medicineName);
    final dosageController =
    TextEditingController(text: reminder.dosage ?? '');
    final freqController =
    TextEditingController(text: reminder.frequency ?? '');
    final durController =
    TextEditingController(text: reminder.duration ?? '');
    List<TimeOfDay> editedTimes = List.from(reminder.times);

    await showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setDialogState) =>
                AlertDialog(
                  title: const Text('Edit Medicine'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                            decoration:
                            const InputDecoration(labelText: 'Medicine Name'),
                            controller: nameController),
                        TextField(
                            decoration: const InputDecoration(
                                labelText: 'Dosage'),
                            controller: dosageController),
                        TextField(
                            decoration: const InputDecoration(
                                labelText: 'Frequency'),
                            controller: freqController),
                        TextField(
                            decoration: const InputDecoration(
                                labelText: 'Duration'),
                            controller: durController),
                        const SizedBox(height: 10),
                        const Text("Reminder Times:"),
                        Wrap(
                          spacing: 8,
                          children: [
                            ...editedTimes.map((t) =>
                                Chip(
                                  label: Text(t.format(context)),
                                  onDeleted: () {
                                    setDialogState(() {
                                      editedTimes.remove(t);
                                    });
                                  },
                                )),
                            ActionChip(
                              label: const Text("Add Time"),
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    editedTimes.add(picked);
                                  });
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel")),
                    ElevatedButton(
                      onPressed: () async {
                        final updated = ReminderModel(
                          medicineName: nameController.text,
                          dosage: dosageController.text,
                          frequency: freqController.text,
                          duration: durController.text,
                          timesPerDay: editedTimes.length,
                          times: editedTimes,
                        );
                        setState(() => _reminders[index] = updated);
                        await _storageService.saveReminders(_reminders);
                        await _notificationService.scheduleReminders(
                            _reminders);
                        Navigator.pop(context);
                      },
                      child: const Text("Save"),
                    )
                  ],
                ),
          ),
    );
  }

  void _deleteReminder(int index) async {
    setState(() => _reminders.removeAt(index));
    await _storageService.saveReminders(_reminders);
    await _notificationService.scheduleReminders(_reminders);
  }

  void _clearAllReminders() async {
    setState(() => _reminders.clear());
    await _storageService.clearReminders();
    await _notificationService.cancelAllNotifications();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediBesti"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: "Prescription Gallery",
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrescriptionGalleryScreen()),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: "Doctor Connect",
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DoctorConnectScreen()),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear All Reminders",
            onPressed: _reminders.isNotEmpty ? _clearAllReminders : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManualMedicine,
        icon: const Icon(Icons.add),
        label: const Text("Add Medicine"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Upload Prescription",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Take a Picture"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text("Choose from Gallery"),
                        ),
                      ],
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, height: 200),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_dailyTip != null)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("💡 Daily Health Tip",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_dailyTip!, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              if (_reminders.isNotEmpty) ...[
                const Text("📋 Extracted Medicines",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ..._reminders
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final reminder = entry.value;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(reminder.medicineName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reminder.dosage != null)
                            Text("Dosage: ${reminder.dosage}"),
                          Wrap(
                            spacing: 6,
                            children: reminder.times
                                .map((time) =>
                                Chip(
                                  label: Text(time.format(context)),
                                  backgroundColor: Colors.deepPurple.shade100,
                                ))
                                .toList(),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                                Icons.edit, color: Colors.deepPurple),
                            onPressed: () => _editReminder(index),
                          ),
                          IconButton(
                            icon: const Icon(
                                Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteReminder(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else
                if (_selectedImage != null) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      "No specific medicine names detected.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
          ],
        ),
      ),
    );
  }
}