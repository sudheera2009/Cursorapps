import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../models/enums.dart';

/// Request payload sent to the isolate. All fields are isolate-sendable.
class PipelineRequest {
  final Uint8List bytes;
  final List<Map<String, dynamic>> opsJson;
  final Map<String, dynamic> encodeJson;

  const PipelineRequest({
    required this.bytes,
    required this.opsJson,
    required this.encodeJson,
  });
}

/// Result returned from the isolate. When [format] is [OutputFormat.webp] the
/// [bytes] are a lossless PNG intermediate that the caller must re-encode to
/// WebP using a native codec (WebP encoding is not available in pure Dart).
class PipelineOutput {
  final Uint8List bytes;
  final int width;
  final int height;
  final OutputFormat format;
  final bool needsWebpEncode;
  final int webpQuality;
  final bool targetMissed;

  const PipelineOutput({
    required this.bytes,
    required this.width,
    required this.height,
    required this.format,
    this.needsWebpEncode = false,
    this.webpQuality = 85,
    this.targetMissed = false,
  });
}

/// Pure, synchronous pipeline. Safe to run inside an isolate (no plugins).
PipelineOutput runPipeline(PipelineRequest req) {
  final decoded = img.decodeImage(req.bytes);
  if (decoded == null) {
    throw const FormatException('Unsupported or corrupt image');
  }

  // Respect EXIF orientation before any geometry ops.
  var image = img.bakeOrientation(decoded);

  final ops = req.opsJson.map(EditOp.fromJson).toList();
  final encode = EncodeSettings.fromJson(req.encodeJson);

  for (final op in ops) {
    image = _applyOp(image, op);
  }

  // Resolve keepOriginal to a concrete format.
  var format = encode.format;
  if (format == OutputFormat.keepOriginal) {
    format = image.hasAlpha ? OutputFormat.png : OutputFormat.jpeg;
  }

  // Strip metadata unless explicitly kept.
  if (!encode.keepExif) {
    image.exif = img.ExifData();
  }

  switch (format) {
    case OutputFormat.png:
      return PipelineOutput(
        bytes: Uint8List.fromList(img.encodePng(image)),
        width: image.width,
        height: image.height,
        format: OutputFormat.png,
      );
    case OutputFormat.webp:
      // Emit a lossless PNG intermediate for the native WebP encoder.
      return PipelineOutput(
        bytes: Uint8List.fromList(img.encodePng(image)),
        width: image.width,
        height: image.height,
        format: OutputFormat.webp,
        needsWebpEncode: true,
        webpQuality: encode.quality,
      );
    case OutputFormat.jpeg:
    case OutputFormat.keepOriginal:
      final flat = _flattenIfNeeded(image, encode.flattenColor);
      return _encodeJpegWithTarget(flat, encode);
  }
}

img.Image _applyOp(img.Image image, EditOp op) {
  switch (op) {
    case ResizeOp o:
      return _resize(image, o);
    case RotateOp o:
      var out = image;
      if (o.degrees % 360 != 0) {
        out = img.copyRotate(out, angle: o.degrees);
      }
      if (o.flipH) out = img.flipHorizontal(out);
      if (o.flipV) out = img.flipVertical(out);
      return out;
    case CropOp o:
      final x = (o.left * image.width).round().clamp(0, image.width - 1);
      final y = (o.top * image.height).round().clamp(0, image.height - 1);
      final w = (o.width * image.width).round().clamp(1, image.width - x);
      final h = (o.height * image.height).round().clamp(1, image.height - y);
      return img.copyCrop(image, x: x, y: y, width: w, height: h);
    case FilterOp o:
      return _filter(image, o.preset);
    case AdjustOp o:
      return _adjust(image, o);
    case WatermarkOp o:
      return _watermark(image, o);
    case RoundCornersOp o:
      return _roundCorners(image, o.radiusPercent);
  }
}

img.Image _resize(img.Image image, ResizeOp o) {
  int? w;
  int? h;
  switch (o.mode) {
    case ResizeMode.none:
      return image;
    case ResizeMode.percentage:
      final pct = (o.percent ?? 100) / 100.0;
      w = math.max(1, (image.width * pct).round());
      h = math.max(1, (image.height * pct).round());
      break;
    case ResizeMode.exact:
      w = o.width;
      h = o.height;
      break;
    case ResizeMode.maxDimension:
      final maxDim = o.maxDim ?? math.max(image.width, image.height);
      if (image.width <= maxDim && image.height <= maxDim) return image;
      if (image.width >= image.height) {
        w = maxDim;
        h = math.max(1, (image.height * maxDim / image.width).round());
      } else {
        h = maxDim;
        w = math.max(1, (image.width * maxDim / image.height).round());
      }
      break;
  }
  if (w == null && h == null) return image;
  final upscaling =
      (w ?? image.width) > image.width || (h ?? image.height) > image.height;
  return img.copyResize(
    image,
    width: w,
    height: h,
    interpolation:
        upscaling ? img.Interpolation.cubic : img.Interpolation.average,
  );
}

img.Image _filter(img.Image image, FilterPreset preset) {
  switch (preset) {
    case FilterPreset.none:
      return image;
    case FilterPreset.grayscale:
      return img.grayscale(image);
    case FilterPreset.sepia:
      return img.sepia(image);
    case FilterPreset.vintage:
      final s = img.sepia(image, amount: 0.6);
      return img.adjustColor(s, contrast: 1.1, saturation: 0.85);
    case FilterPreset.vivid:
      return img.adjustColor(image, saturation: 1.5, contrast: 1.08);
    case FilterPreset.cool:
      return img.colorOffset(image, red: -12, green: 0, blue: 20);
    case FilterPreset.warm:
      return img.colorOffset(image, red: 22, green: 8, blue: -12);
    case FilterPreset.invert:
      return img.invert(image);
  }
}

img.Image _adjust(img.Image image, AdjustOp o) {
  var out = image;
  if (o.brightness != 1.0 || o.contrast != 1.0 || o.saturation != 1.0) {
    out = img.adjustColor(
      out,
      brightness: o.brightness,
      contrast: o.contrast,
      saturation: o.saturation,
    );
  }
  if (o.sharpen > 0) {
    final a = o.sharpen.clamp(0.0, 1.0);
    // Blend an identity kernel with a sharpen kernel by [a].
    final center = 1 + 4 * a;
    final side = -a;
    out = img.convolution(
      out,
      filter: [0, side, 0, side, center, side, 0, side, 0],
      div: 1,
      offset: 0,
    );
  }
  return out;
}

img.Image _watermark(img.Image image, WatermarkOp o) {
  if (o.text.trim().isEmpty) return image;
  final minSide = math.min(image.width, image.height);
  final font = minSide >= 1200
      ? img.arial48
      : (minSide >= 500 ? img.arial24 : img.arial14);
  final alpha = (o.opacity.clamp(0.0, 1.0) * 255).round();
  final color = img.ColorRgba8(255, 255, 255, alpha);
  final shadow = img.ColorRgba8(0, 0, 0, (alpha * 0.6).round());

  // Rough text metrics for placement.
  final textW = (o.text.length * font.characters[32]!.width * 0.62).round();
  final textH = font.lineHeight;
  final pad = (minSide * 0.03).round();

  void stamp(int x, int y) {
    img.drawString(image, o.text, font: font, x: x + 1, y: y + 1, color: shadow);
    img.drawString(image, o.text, font: font, x: x, y: y, color: color);
  }

  switch (o.position) {
    case WatermarkPosition.topLeft:
      stamp(pad, pad);
      break;
    case WatermarkPosition.topRight:
      stamp(image.width - textW - pad, pad);
      break;
    case WatermarkPosition.center:
      stamp((image.width - textW) ~/ 2, (image.height - textH) ~/ 2);
      break;
    case WatermarkPosition.bottomLeft:
      stamp(pad, image.height - textH - pad);
      break;
    case WatermarkPosition.bottomRight:
      stamp(image.width - textW - pad, image.height - textH - pad);
      break;
    case WatermarkPosition.tiled:
      final stepX = textW + pad * 3;
      final stepY = textH + pad * 3;
      for (int y = pad; y < image.height; y += stepY) {
        for (int x = pad; x < image.width; x += stepX) {
          stamp(x, y);
        }
      }
      break;
  }
  return image;
}

img.Image _roundCorners(img.Image image, double radiusPercent) {
  final r =
      (math.min(image.width, image.height) * radiusPercent.clamp(0.0, 0.5))
          .round();
  if (r <= 0) return image;
  final out = image.numChannels == 4 ? image : image.convert(numChannels: 4);
  for (int y = 0; y < out.height; y++) {
    for (int x = 0; x < out.width; x++) {
      final inCorner = _cornerDistanceExceedsRadius(x, y, out.width, out.height, r);
      if (inCorner) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

bool _cornerDistanceExceedsRadius(int x, int y, int w, int h, int r) {
  // Top-left
  if (x < r && y < r) {
    final dx = r - x, dy = r - y;
    return dx * dx + dy * dy > r * r;
  }
  // Top-right
  if (x >= w - r && y < r) {
    final dx = x - (w - r - 1), dy = r - y;
    return dx * dx + dy * dy > r * r;
  }
  // Bottom-left
  if (x < r && y >= h - r) {
    final dx = r - x, dy = y - (h - r - 1);
    return dx * dx + dy * dy > r * r;
  }
  // Bottom-right
  if (x >= w - r && y >= h - r) {
    final dx = x - (w - r - 1), dy = y - (h - r - 1);
    return dx * dx + dy * dy > r * r;
  }
  return false;
}

img.Image _flattenIfNeeded(img.Image image, int flattenColor) {
  if (!image.hasAlpha) return image;
  final a = (flattenColor >> 24) & 0xFF;
  final r = (flattenColor >> 16) & 0xFF;
  final g = (flattenColor >> 8) & 0xFF;
  final b = flattenColor & 0xFF;
  final bg = img.Image(width: image.width, height: image.height, numChannels: 3);
  img.fill(bg, color: img.ColorRgba8(r, g, b, a));
  img.compositeImage(bg, image);
  return bg;
}

PipelineOutput _encodeJpegWithTarget(img.Image image, EncodeSettings encode) {
  final target = encode.targetSizeKb;
  if (target == null) {
    final bytes = img.encodeJpg(image, quality: encode.quality);
    return PipelineOutput(
      bytes: Uint8List.fromList(bytes),
      width: image.width,
      height: image.height,
      format: OutputFormat.jpeg,
    );
  }

  final targetBytes = target * 1024;
  int lo = 10, hi = 95;
  List<int> best = img.encodeJpg(image, quality: hi);
  // Binary search the highest quality that fits under the target.
  while (lo <= hi) {
    final mid = (lo + hi) ~/ 2;
    final candidate = img.encodeJpg(image, quality: mid);
    if (candidate.length <= targetBytes) {
      best = candidate;
      lo = mid + 1;
    } else {
      hi = mid - 1;
    }
  }

  var working = image;
  var out = best;
  // If still too big at min quality, progressively downscale.
  int guard = 0;
  while (out.length > targetBytes && guard < 6) {
    final newW = (working.width * 0.85).round();
    final newH = (working.height * 0.85).round();
    if (newW < 32 || newH < 32) break;
    working = img.copyResize(working,
        width: newW, height: newH, interpolation: img.Interpolation.average);
    out = img.encodeJpg(working, quality: 60);
    guard++;
  }

  return PipelineOutput(
    bytes: Uint8List.fromList(out),
    width: working.width,
    height: working.height,
    format: OutputFormat.jpeg,
    targetMissed: out.length > targetBytes,
  );
}
