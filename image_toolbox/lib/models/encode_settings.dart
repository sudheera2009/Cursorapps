import 'enums.dart';

/// Controls the final encode step of the pipeline.
class EncodeSettings {
  final OutputFormat format;
  final int quality; // 1..100 (lossy formats)
  final int? targetSizeKb; // when set, quality is auto-tuned to hit this size
  final int flattenColor; // 0xAARRGGBB background for alpha loss
  final bool keepExif;

  const EncodeSettings({
    this.format = OutputFormat.jpeg,
    this.quality = 85,
    this.targetSizeKb,
    this.flattenColor = 0xFFFFFFFF,
    this.keepExif = false,
  });

  EncodeSettings copyWith({
    OutputFormat? format,
    int? quality,
    int? targetSizeKb,
    bool clearTargetSize = false,
    int? flattenColor,
    bool? keepExif,
  }) {
    return EncodeSettings(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      targetSizeKb: clearTargetSize ? null : (targetSizeKb ?? this.targetSizeKb),
      flattenColor: flattenColor ?? this.flattenColor,
      keepExif: keepExif ?? this.keepExif,
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format.name,
        'quality': quality,
        'targetSizeKb': targetSizeKb,
        'flattenColor': flattenColor,
        'keepExif': keepExif,
      };

  factory EncodeSettings.fromJson(Map<String, dynamic> j) => EncodeSettings(
        format: OutputFormat.values.byName(j['format'] as String? ?? 'jpeg'),
        quality: j['quality'] as int? ?? 85,
        targetSizeKb: j['targetSizeKb'] as int?,
        flattenColor: j['flattenColor'] as int? ?? 0xFFFFFFFF,
        keepExif: j['keepExif'] as bool? ?? false,
      );
}
