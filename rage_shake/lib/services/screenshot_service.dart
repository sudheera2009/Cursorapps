import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal();

  // Capture a widget to image bytes
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Screenshot capture failed: $e');
      return null;
    }
  }

  // Save screenshot to file
  Future<File?> saveScreenshot(Uint8List bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final rageClipsDir = Directory('${directory.path}/rage_clips');
      if (!await rageClipsDir.exists()) {
        await rageClipsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${rageClipsDir.path}/${fileName}_$timestamp.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Screenshot save failed: $e');
      return null;
    }
  }

  // Share screenshot
  Future<void> shareScreenshot(Uint8List bytes, {String? text}) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/rage_clip_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? '🔥 Check out my RAGE SHAKE score! #RageShake',
      );
    } catch (e) {
      debugPrint('Screenshot share failed: $e');
    }
  }

  // Get all saved rage clips
  Future<List<File>> getSavedClips() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final rageClipsDir = Directory('${directory.path}/rage_clips');
      if (!await rageClipsDir.exists()) {
        return [];
      }

      final files = await rageClipsDir.list().toList();
      return files
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
    } catch (e) {
      debugPrint('Get clips failed: $e');
      return [];
    }
  }

  // Delete a rage clip
  Future<bool> deleteClip(File file) async {
    try {
      await file.delete();
      return true;
    } catch (e) {
      debugPrint('Delete clip failed: $e');
      return false;
    }
  }

  // Create share text based on stats
  String createShareText({
    required int damage,
    required int objects,
    required int combo,
    required String mode,
  }) {
    final damageStr = _formatDamage(damage);
    return '🔥 RAGE SHAKE 🔥\n'
        '💰 Damage: $damageStr\n'
        '💥 Objects: $objects\n'
        '⚡ Max Combo: ${combo}x\n'
        '🎯 Mode: $mode\n\n'
        '#RageShake #MobileGame';
  }

  String _formatDamage(int damage) {
    if (damage >= 1000000000) return '\$${(damage / 1000000000).toStringAsFixed(1)}B';
    if (damage >= 1000000) return '\$${(damage / 1000000).toStringAsFixed(1)}M';
    if (damage >= 1000) return '\$${(damage / 1000).toStringAsFixed(1)}K';
    return '\$$damage';
  }
}
