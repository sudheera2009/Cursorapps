import 'enums.dart';

/// A single, serializable transformation applied by the image pipeline.
///
/// Ops are JSON-serializable so a list of them can be stored as a [Recipe] or
/// as part of a saved project.
sealed class EditOp {
  const EditOp();

  String get type;

  Map<String, dynamic> toJson();

  static EditOp fromJson(Map<String, dynamic> j) {
    switch (j['type'] as String) {
      case 'resize':
        return ResizeOp.fromJson(j);
      case 'rotate':
        return RotateOp.fromJson(j);
      case 'crop':
        return CropOp.fromJson(j);
      case 'filter':
        return FilterOp.fromJson(j);
      case 'adjust':
        return AdjustOp.fromJson(j);
      case 'watermark':
        return WatermarkOp.fromJson(j);
      case 'roundCorners':
        return RoundCornersOp.fromJson(j);
      default:
        throw ArgumentError('Unknown EditOp type: ${j['type']}');
    }
  }
}

class ResizeOp extends EditOp {
  final ResizeMode mode;
  final int? width;
  final int? height;
  final int? maxDim;
  final double? percent;

  const ResizeOp({
    required this.mode,
    this.width,
    this.height,
    this.maxDim,
    this.percent,
  });

  @override
  String get type => 'resize';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'mode': mode.name,
        'width': width,
        'height': height,
        'maxDim': maxDim,
        'percent': percent,
      };

  factory ResizeOp.fromJson(Map<String, dynamic> j) => ResizeOp(
        mode: ResizeMode.values.byName(j['mode'] as String),
        width: j['width'] as int?,
        height: j['height'] as int?,
        maxDim: j['maxDim'] as int?,
        percent: (j['percent'] as num?)?.toDouble(),
      );
}

class RotateOp extends EditOp {
  final int degrees; // 90, 180, 270
  final bool flipH;
  final bool flipV;

  const RotateOp({this.degrees = 0, this.flipH = false, this.flipV = false});

  @override
  String get type => 'rotate';

  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'degrees': degrees, 'flipH': flipH, 'flipV': flipV};

  factory RotateOp.fromJson(Map<String, dynamic> j) => RotateOp(
        degrees: j['degrees'] as int? ?? 0,
        flipH: j['flipH'] as bool? ?? false,
        flipV: j['flipV'] as bool? ?? false,
      );
}

/// Fractional crop rectangle (0..1) so it is resolution-independent.
class CropOp extends EditOp {
  final double left, top, width, height;

  const CropOp({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  String get type => 'crop';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      };

  factory CropOp.fromJson(Map<String, dynamic> j) => CropOp(
        left: (j['left'] as num).toDouble(),
        top: (j['top'] as num).toDouble(),
        width: (j['width'] as num).toDouble(),
        height: (j['height'] as num).toDouble(),
      );
}

class FilterOp extends EditOp {
  final FilterPreset preset;

  const FilterOp(this.preset);

  @override
  String get type => 'filter';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'preset': preset.name};

  factory FilterOp.fromJson(Map<String, dynamic> j) =>
      FilterOp(FilterPreset.values.byName(j['preset'] as String));
}

/// Manual color adjustments. Neutral values: brightness 1.0, contrast 1.0,
/// saturation 1.0, sharpen 0.0.
class AdjustOp extends EditOp {
  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpen;

  const AdjustOp({
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.sharpen = 0.0,
  });

  bool get isNeutral =>
      brightness == 1.0 &&
      contrast == 1.0 &&
      saturation == 1.0 &&
      sharpen == 0.0;

  @override
  String get type => 'adjust';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
        'sharpen': sharpen,
      };

  factory AdjustOp.fromJson(Map<String, dynamic> j) => AdjustOp(
        brightness: (j['brightness'] as num?)?.toDouble() ?? 1.0,
        contrast: (j['contrast'] as num?)?.toDouble() ?? 1.0,
        saturation: (j['saturation'] as num?)?.toDouble() ?? 1.0,
        sharpen: (j['sharpen'] as num?)?.toDouble() ?? 0.0,
      );
}

class WatermarkOp extends EditOp {
  final String text;
  final WatermarkPosition position;
  final double opacity; // 0..1
  final double scale; // relative size, 1.0 = default

  const WatermarkOp({
    required this.text,
    this.position = WatermarkPosition.bottomRight,
    this.opacity = 0.6,
    this.scale = 1.0,
  });

  @override
  String get type => 'watermark';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
        'position': position.name,
        'opacity': opacity,
        'scale': scale,
      };

  factory WatermarkOp.fromJson(Map<String, dynamic> j) => WatermarkOp(
        text: j['text'] as String? ?? '',
        position:
            WatermarkPosition.values.byName(j['position'] as String? ?? 'bottomRight'),
        opacity: (j['opacity'] as num?)?.toDouble() ?? 0.6,
        scale: (j['scale'] as num?)?.toDouble() ?? 1.0,
      );
}

class RoundCornersOp extends EditOp {
  final double radiusPercent; // 0..0.5 of the smaller side

  const RoundCornersOp({this.radiusPercent = 0.1});

  @override
  String get type => 'roundCorners';

  @override
  Map<String, dynamic> toJson() =>
      {'type': type, 'radiusPercent': radiusPercent};

  factory RoundCornersOp.fromJson(Map<String, dynamic> j) => RoundCornersOp(
        radiusPercent: (j['radiusPercent'] as num?)?.toDouble() ?? 0.1,
      );
}
