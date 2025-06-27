import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_storage_service.dart';

class PrescriptionGalleryScreen extends StatefulWidget {
  const PrescriptionGalleryScreen({super.key});

  @override
  State<PrescriptionGalleryScreen> createState() => _PrescriptionGalleryScreenState();
}

class _PrescriptionGalleryScreenState extends State<PrescriptionGalleryScreen> {
  final ImageStorageService _imageService = ImageStorageService();
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final paths = await _imageService.loadSavedImagePaths();
    setState(() {
      _imagePaths = paths;
    });
  }

  Future<void> _deleteImage(String path) async {
    await _imageService.deleteImage(path);
    _loadImages();
  }

  void _previewImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.file(File(path), fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Gallery'),
      ),
      body: _imagePaths.isEmpty
          ? const Center(child: Text("No saved prescriptions."))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _imagePaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final path = _imagePaths[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _previewImage(path),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _deleteImage(path),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.delete, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
