import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const _imageKey = 'saved_prescription_images';
  final Uuid _uuid = Uuid();

  /// Save image to app directory with unique name
  Future<String> saveImage(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = path.extension(imageFile.path);
    final fileName = '${_uuid.v4()}$ext';
    final newPath = path.join(dir.path, fileName);
    final newImage = await imageFile.copy(newPath);

    final prefs = await SharedPreferences.getInstance();
    final List<String> paths = prefs.getStringList(_imageKey) ?? [];
    if (!paths.contains(newImage.path)) {
      paths.add(newImage.path);
      await prefs.setStringList(_imageKey, paths);
    }

    return newImage.path;
  }

  /// Return list of saved image paths
  Future<List<String>> loadSavedImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_imageKey) ?? [];
  }

  /// Delete image from local and from saved list
  Future<void> deleteImage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_imageKey) ?? [];
    paths.remove(filePath);
    await prefs.setStringList(_imageKey, paths);
  }

  /// Clear all saved images
  Future<void> clearAllImages() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList(_imageKey) ?? [];
    for (String filePath in paths) {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await prefs.remove(_imageKey);
  }

  /// Helper to get File from path
  Future<File> getImageFile(String filePath) async {
    return File(filePath);
  }
}
