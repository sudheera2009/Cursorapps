import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/image_job.dart';

/// Handles sharing single/multiple results and ZIP export.
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<void> shareBytes(Uint8List bytes, String name, {String? text}) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, name));
      await file.writeAsBytes(bytes);
      await SharePlus.instance
          .share(ShareParams(files: [XFile(file.path)], text: text));
    } catch (e) {
      debugPrint('Share failed: $e');
    }
  }

  Future<void> shareJobs(List<ImageJob> jobs, {String? text}) async {
    try {
      final dir = await getTemporaryDirectory();
      final files = <XFile>[];
      for (final j in jobs) {
        final r = j.result;
        if (r == null) continue;
        final file = File(p.join(dir.path, r.suggestedName));
        await file.writeAsBytes(r.bytes);
        files.add(XFile(file.path));
      }
      if (files.isEmpty) return;
      await SharePlus.instance.share(ShareParams(files: files, text: text));
    } catch (e) {
      debugPrint('Share batch failed: $e');
    }
  }

  /// Bundles all results into a single .zip and shares it.
  Future<void> exportZip(List<ImageJob> jobs) async {
    try {
      final archive = Archive();
      for (final j in jobs) {
        final r = j.result;
        if (r == null) continue;
        archive.addFile(
            ArchiveFile(r.suggestedName, r.bytes.length, r.bytes));
      }
      if (archive.isEmpty) return;
      final zipData = ZipEncoder().encode(archive);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile = File(p.join(dir.path, 'image_toolbox_$stamp.zip'));
      await zipFile.writeAsBytes(zipData);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(zipFile.path)],
        text: 'Processed with Image Toolbox',
      ));
    } catch (e) {
      debugPrint('ZIP export failed: $e');
    }
  }
}
