import 'package:path/path.dart' as p;

/// Human-readable helpers used across the UI.
class Formatters {
  static String bytes(int b) {
    if (b < 0) return '0 B';
    if (b < 1024) return '$b B';
    if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(1)} KB';
    if (b < 1024 * 1024 * 1024) {
      return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(b / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String percent(double ratio) => '${(ratio * 100).round()}%';

  static String dimensions(int w, int h) => '$w × $h';

  /// Builds an output filename like `photo_toolbox.jpg`, avoiding collisions by
  /// appending a counter when [index] > 0.
  static String outputName(String sourcePath, String extension,
      {String suffix = 'toolbox', int index = 0}) {
    final base = p.basenameWithoutExtension(sourcePath);
    final safeBase = base.isEmpty ? 'image' : base;
    final counter = index > 0 ? '_$index' : '';
    return '${safeBase}_$suffix$counter.$extension';
  }
}
