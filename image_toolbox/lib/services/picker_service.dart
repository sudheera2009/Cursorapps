import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/image_job.dart';

/// Wraps image selection from the gallery and camera.
class PickerService {
  static final PickerService _instance = PickerService._internal();
  factory PickerService() => _instance;
  PickerService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<List<ImageJob>> pickFromGallery() async {
    try {
      final files = await _picker.pickMultiImage();
      return _toJobs(files);
    } catch (e) {
      debugPrint('Gallery pick failed: $e');
      return [];
    }
  }

  Future<List<ImageJob>> pickFromCamera() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      return _toJobs(file == null ? [] : [file]);
    } catch (e) {
      debugPrint('Camera pick failed: $e');
      return [];
    }
  }

  Future<List<ImageJob>> _toJobs(List<XFile> files) async {
    final jobs = <ImageJob>[];
    for (final f in files) {
      final bytes = await f.readAsBytes();
      jobs.add(ImageJob(sourcePath: f.name, sourceBytes: bytes));
    }
    return jobs;
  }
}
