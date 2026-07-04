import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/enums.dart';

/// App-wide defaults and lifetime usage stats.
class SettingsProvider extends ChangeNotifier {
  OutputFormat defaultFormat = OutputFormat.jpeg;
  int defaultQuality = 85;
  bool keepExif = false;
  bool saveToGallery = true;

  // Lifetime stats for the dashboard.
  int filesProcessed = 0;
  int bytesSaved = 0;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    defaultFormat = OutputFormat
        .values[prefs.getInt('defaultFormat') ?? OutputFormat.jpeg.index];
    defaultQuality = prefs.getInt('defaultQuality') ?? 85;
    keepExif = prefs.getBool('keepExif') ?? false;
    saveToGallery = prefs.getBool('saveToGallery') ?? true;
    filesProcessed = prefs.getInt('filesProcessed') ?? 0;
    bytesSaved = prefs.getInt('bytesSaved') ?? 0;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultFormat', defaultFormat.index);
    await prefs.setInt('defaultQuality', defaultQuality);
    await prefs.setBool('keepExif', keepExif);
    await prefs.setBool('saveToGallery', saveToGallery);
    await prefs.setInt('filesProcessed', filesProcessed);
    await prefs.setInt('bytesSaved', bytesSaved);
  }

  void setDefaultFormat(OutputFormat f) {
    defaultFormat = f;
    _save();
    notifyListeners();
  }

  void setDefaultQuality(int q) {
    defaultQuality = q.clamp(1, 100);
    _save();
    notifyListeners();
  }

  void setKeepExif(bool v) {
    keepExif = v;
    _save();
    notifyListeners();
  }

  void setSaveToGallery(bool v) {
    saveToGallery = v;
    _save();
    notifyListeners();
  }

  /// Record a completed job for the lifetime dashboard.
  void recordProcessed({required int savedBytes}) {
    filesProcessed += 1;
    // Only count positive savings so the "space saved" figure stays intuitive.
    if (savedBytes > 0) bytesSaved += savedBytes;
    _save();
    notifyListeners();
  }

  Future<void> resetStats() async {
    filesProcessed = 0;
    bytesSaved = 0;
    await _save();
    notifyListeners();
  }
}
