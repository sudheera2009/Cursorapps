/// Output image formats supported by the pipeline.
enum OutputFormat { keepOriginal, jpeg, png, webp }

extension OutputFormatInfo on OutputFormat {
  String get label {
    switch (this) {
      case OutputFormat.keepOriginal:
        return 'Original';
      case OutputFormat.jpeg:
        return 'JPEG';
      case OutputFormat.png:
        return 'PNG';
      case OutputFormat.webp:
        return 'WebP';
    }
  }

  String get extension {
    switch (this) {
      case OutputFormat.keepOriginal:
        return '';
      case OutputFormat.jpeg:
        return 'jpg';
      case OutputFormat.png:
        return 'png';
      case OutputFormat.webp:
        return 'webp';
    }
  }

  /// Whether the format is lossy (quality slider / target-size are meaningful).
  bool get isLossy =>
      this == OutputFormat.jpeg || this == OutputFormat.webp;

  /// Whether the format supports transparency.
  bool get supportsAlpha => this == OutputFormat.png || this == OutputFormat.webp;
}

/// How an image should be resized.
enum ResizeMode { none, percentage, exact, maxDimension }

/// Lifecycle of a single image job in a batch.
enum JobStatus { queued, processing, done, error }

/// Grouping of tools on the hub screen.
enum ToolCategory { optimize, edit, create, extract }

extension ToolCategoryInfo on ToolCategory {
  String get label {
    switch (this) {
      case ToolCategory.optimize:
        return 'Optimize';
      case ToolCategory.edit:
        return 'Edit';
      case ToolCategory.create:
        return 'Create';
      case ToolCategory.extract:
        return 'Extract';
    }
  }
}

/// Named photo filter presets.
enum FilterPreset { none, grayscale, sepia, vintage, vivid, cool, warm, invert }

extension FilterPresetInfo on FilterPreset {
  String get label {
    switch (this) {
      case FilterPreset.none:
        return 'None';
      case FilterPreset.grayscale:
        return 'Mono';
      case FilterPreset.sepia:
        return 'Sepia';
      case FilterPreset.vintage:
        return 'Vintage';
      case FilterPreset.vivid:
        return 'Vivid';
      case FilterPreset.cool:
        return 'Cool';
      case FilterPreset.warm:
        return 'Warm';
      case FilterPreset.invert:
        return 'Invert';
    }
  }
}

/// Anchor position for watermarks.
enum WatermarkPosition {
  topLeft,
  topRight,
  center,
  bottomLeft,
  bottomRight,
  tiled,
}

extension WatermarkPositionInfo on WatermarkPosition {
  String get label {
    switch (this) {
      case WatermarkPosition.topLeft:
        return 'Top Left';
      case WatermarkPosition.topRight:
        return 'Top Right';
      case WatermarkPosition.center:
        return 'Center';
      case WatermarkPosition.bottomLeft:
        return 'Bottom Left';
      case WatermarkPosition.bottomRight:
        return 'Bottom Right';
      case WatermarkPosition.tiled:
        return 'Tiled';
    }
  }
}
