import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Saves processed images to disk and the device gallery.
class GalleryService {
  static final GalleryService _instance = GalleryService._internal();
  factory GalleryService() => _instance;
  GalleryService._internal();

  static const String album = 'Image Toolbox';

  /// Writes [bytes] to a temp file and returns its path.
  Future<String> writeTemp(Uint8List bytes, String name) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Saves [bytes] to the device gallery. Returns true on success.
  Future<bool> saveToGallery(Uint8List bytes, String name) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }
      final path = await writeTemp(bytes, name);
      await Gal.putImage(path, album: album);
      return true;
    } catch (e) {
      debugPrint('Save to gallery failed: $e');
      return false;
    }
  }
}
