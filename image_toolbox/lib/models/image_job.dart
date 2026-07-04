import 'dart:typed_data';

import 'enums.dart';
import 'process_result.dart';

/// A single source image queued for processing.
class ImageJob {
  final String sourcePath;
  final Uint8List sourceBytes;
  JobStatus status;
  ProcessResult? result;
  String? error;

  ImageJob({
    required this.sourcePath,
    required this.sourceBytes,
    this.status = JobStatus.queued,
    this.result,
    this.error,
  });

  int get originalBytes => sourceBytes.length;
}
