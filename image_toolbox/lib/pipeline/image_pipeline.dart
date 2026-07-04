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

    // Pure Dart cannot encode WebP; finish that step with the native codec.
    if (output.needsWebpEncode) {
      try {
        final webp = await FlutterImageCompress.compressWithList(
          output.bytes,
          format: CompressFormat.webp,
          quality: output.webpQuality,
        );
        finalBytes = webp;
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
      targetMissed: output.targetMissed,
    );
  }
}
