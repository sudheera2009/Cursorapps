import 'dart:typed_data';
import 'enums.dart';

/// The output of running the pipeline on one image.
class ProcessResult {
  final Uint8List bytes;
  final String suggestedName;
  final int originalBytes;
  final int width;
  final int height;
  final OutputFormat format;
  final int elapsedMs;

  /// True when a target size was requested but could not be fully reached.
  final bool targetMissed;

  const ProcessResult({
    required this.bytes,
    required this.suggestedName,
    required this.originalBytes,
    required this.width,
    required this.height,
    required this.format,
    this.elapsedMs = 0,
    this.targetMissed = false,
  });

  int get newBytes => bytes.length;
  int get savedBytes => originalBytes - newBytes;
  double get savedPercent =>
      originalBytes == 0 ? 0 : savedBytes / originalBytes;
  bool get gotLarger => newBytes > originalBytes;
}
