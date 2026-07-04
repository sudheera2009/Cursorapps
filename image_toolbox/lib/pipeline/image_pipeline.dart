import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../core/formatters.dart';
import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../models/enums.dart';
import '../models/process_result.dart';
import 'pipeline_runner.dart';

/// High-level entry point for running the image pipeline off the UI thread.
class ImagePipeline {
  static final ImagePipeline _instance = ImagePipeline._internal();
  factory ImagePipeline() => _instance;
  ImagePipeline._internal();

  /// Processes [bytes] with [ops] and [encode], returning the encoded result.
  Future<ProcessResult> process({
    required Uint8List bytes,
    required String sourceName,
    required List<EditOp> ops,
    required EncodeSettings encode,
    int outputIndex = 0,
  }) async {
    final started = DateTime.now();

    final request = PipelineRequest(
      bytes: bytes,
      opsJson: ops.map((o) => o.toJson()).toList(),
      encodeJson: encode.toJson(),
    );

    // Heavy pixel work runs in a background isolate.
    final PipelineOutput output = await compute(runPipeline, request);

    var finalBytes = output.bytes;
    var format = output.format;
    var targetMissed = output.targetMissed;

    // Pure Dart cannot encode WebP; finish that step with the native codec.
    if (output.needsWebpEncode) {
      try {
        final result = await _encodeWebp(output);
        finalBytes = result.$1;
        targetMissed = result.$2;
      } catch (e) {
        // Fall back to the PNG intermediate if WebP is unavailable.
        debugPrint('WebP encode failed, falling back to PNG: $e');
        format = OutputFormat.png;
      }
    }

    final name = Formatters.outputName(
      sourceName,
      format.extension.isEmpty ? 'jpg' : format.extension,
      index: outputIndex,
    );

    return ProcessResult(
      bytes: finalBytes,
      suggestedName: name,
      originalBytes: bytes.length,
      width: output.width,
      height: output.height,
      format: format,
      elapsedMs: DateTime.now().difference(started).inMilliseconds,
      targetMissed: targetMissed,
    );
  }

  /// Encodes the PNG intermediate to WebP with the native codec. When a target
  /// size is set, binary-searches quality to fit it. Returns (bytes, missed).
  Future<(Uint8List, bool)> _encodeWebp(PipelineOutput output) async {
    // Pass the intermediate's own dimensions so the codec never downscales.
    Future<Uint8List> encodeAt(int quality) =>
        FlutterImageCompress.compressWithList(
          output.bytes,
          format: CompressFormat.webp,
          quality: quality,
          minWidth: output.width,
          minHeight: output.height,
          autoCorrectionAngle: false,
          keepExif: output.keepExif,
        );

    final targetKb = output.webpTargetKb;
    if (targetKb == null) {
      return (await encodeAt(output.webpQuality), false);
    }

    final targetBytes = targetKb * 1024;
    int lo = 10, hi = 95;
    Uint8List best = await encodeAt(hi);
    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;
      final candidate = await encodeAt(mid);
      if (candidate.length <= targetBytes) {
        best = candidate;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return (best, best.length > targetBytes);
  }
}
