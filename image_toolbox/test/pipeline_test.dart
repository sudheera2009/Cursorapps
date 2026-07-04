import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:image_toolbox/core/formatters.dart';
import 'package:image_toolbox/models/edit_op.dart';
import 'package:image_toolbox/models/encode_settings.dart';
import 'package:image_toolbox/models/enums.dart';
import 'package:image_toolbox/models/recipe.dart';
import 'package:image_toolbox/pipeline/pipeline_runner.dart';

Uint8List _makeImage(int w, int h, {bool noise = false, bool alpha = false}) {
  final image =
      img.Image(width: w, height: h, numChannels: alpha ? 4 : 3);
  final rnd = Random(1);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final r = noise ? rnd.nextInt(256) : (x * 255 ~/ w);
      final g = noise ? rnd.nextInt(256) : (y * 255 ~/ h);
      final b = noise ? rnd.nextInt(256) : 128;
      image.setPixelRgba(x, y, r, g, b, alpha ? 128 : 255);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

PipelineOutput _run(
  Uint8List bytes,
  List<EditOp> ops,
  EncodeSettings encode,
) {
  return runPipeline(PipelineRequest(
    bytes: bytes,
    opsJson: ops.map((o) => o.toJson()).toList(),
    encodeJson: encode.toJson(),
  ));
}

void main() {
  group('pipeline resize', () {
    test('percentage halves dimensions', () {
      final src = _makeImage(200, 100);
      final out = _run(
        src,
        [const ResizeOp(mode: ResizeMode.percentage, percent: 50)],
        const EncodeSettings(format: OutputFormat.png),
      );
      expect(out.width, 100);
      expect(out.height, 50);
    });

    test('maxDimension caps the longest side and keeps aspect', () {
      final src = _makeImage(400, 200);
      final out = _run(
        src,
        [const ResizeOp(mode: ResizeMode.maxDimension, maxDim: 100)],
        const EncodeSettings(format: OutputFormat.png),
      );
      expect(out.width, 100);
      expect(out.height, 50);
    });

    test('exact sets both dimensions', () {
      final src = _makeImage(200, 200);
      final out = _run(
        src,
        [const ResizeOp(mode: ResizeMode.exact, width: 64, height: 48)],
        const EncodeSettings(format: OutputFormat.png),
      );
      expect(out.width, 64);
      expect(out.height, 48);
    });
  });

  group('pipeline rotate', () {
    test('90 degrees swaps width and height', () {
      final src = _makeImage(120, 60);
      final out = _run(
        src,
        [const RotateOp(degrees: 90)],
        const EncodeSettings(format: OutputFormat.png),
      );
      expect(out.width, 60);
      expect(out.height, 120);
    });
  });

  group('pipeline crop', () {
    test('fractional crop takes the requested region', () {
      final src = _makeImage(200, 200);
      final out = _run(
        src,
        [const CropOp(left: 0.25, top: 0.25, width: 0.5, height: 0.5)],
        const EncodeSettings(format: OutputFormat.png),
      );
      expect(out.width, 100);
      expect(out.height, 100);
    });
  });

  group('pipeline encode', () {
    test('jpeg output is decodable as jpeg', () {
      final src = _makeImage(64, 64);
      final out = _run(
        src,
        const [],
        const EncodeSettings(format: OutputFormat.jpeg, quality: 80),
      );
      expect(out.format, OutputFormat.jpeg);
      final decoded = img.decodeJpg(out.bytes);
      expect(decoded, isNotNull);
    });

    test('target size search stays under the requested budget', () {
      final src = _makeImage(400, 400, noise: true);
      const targetKb = 20;
      final out = _run(
        src,
        const [],
        const EncodeSettings(format: OutputFormat.jpeg, targetSizeKb: targetKb),
      );
      // Either it fit under budget, or it honestly reports it missed.
      expect(out.bytes.length <= targetKb * 1024 || out.targetMissed, isTrue);
    });

    test('png keeps alpha channel', () {
      final src = _makeImage(32, 32, alpha: true);
      final out = _run(
        src,
        const [],
        const EncodeSettings(format: OutputFormat.png),
      );
      final decoded = img.decodePng(out.bytes);
      expect(decoded, isNotNull);
      expect(decoded!.hasAlpha, isTrue);
    });

    test('keepOriginal resolves alpha images to png', () {
      final src = _makeImage(32, 32, alpha: true);
      final out = _run(
        src,
        const [],
        const EncodeSettings(format: OutputFormat.keepOriginal),
      );
      expect(out.format, OutputFormat.png);
    });
  });

  group('serialization', () {
    test('every EditOp round-trips through JSON', () {
      final ops = <EditOp>[
        const ResizeOp(mode: ResizeMode.maxDimension, maxDim: 1080),
        const RotateOp(degrees: 90, flipH: true),
        const CropOp(left: 0.1, top: 0.1, width: 0.8, height: 0.8),
        const FilterOp(FilterPreset.vintage),
        const AdjustOp(brightness: 1.1, contrast: 1.2, saturation: 0.9, sharpen: 0.3),
        const WatermarkOp(text: 'hello', position: WatermarkPosition.tiled),
        const RoundCornersOp(radiusPercent: 0.2),
      ];
      for (final op in ops) {
        final restored = EditOp.fromJson(op.toJson());
        expect(restored.type, op.type);
        expect(restored.toJson(), op.toJson());
      }
    });

    test('recipe list encodes and decodes', () {
      final recipes = [
        Recipe(
          id: 'r1',
          name: 'Web ready',
          emoji: '🌐',
          ops: const [ResizeOp(mode: ResizeMode.maxDimension, maxDim: 1600)],
          encode: const EncodeSettings(
              format: OutputFormat.jpeg, targetSizeKb: 300),
        ),
      ];
      final decoded = Recipe.decodeList(Recipe.encodeList(recipes));
      expect(decoded.length, 1);
      expect(decoded.first.name, 'Web ready');
      expect(decoded.first.ops.length, 1);
      expect(decoded.first.encode.targetSizeKb, 300);
    });
  });

  group('formatters', () {
    test('bytes formats magnitudes', () {
      expect(Formatters.bytes(512), '512 B');
      expect(Formatters.bytes(2048), '2.0 KB');
      expect(Formatters.bytes(5 * 1024 * 1024), '5.0 MB');
    });

    test('outputName builds a suffixed filename', () {
      expect(
        Formatters.outputName('/a/b/photo.png', 'jpg'),
        'photo_toolbox.jpg',
      );
      expect(
        Formatters.outputName('/a/b/photo.png', 'jpg', index: 2),
        'photo_toolbox_2.jpg',
      );
    });
  });
}
