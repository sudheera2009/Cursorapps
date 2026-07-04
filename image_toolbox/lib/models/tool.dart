import 'enums.dart';

/// Identifiers for every tool available in the MVP.
enum ToolId {
  compress,
  resize,
  convert,
  cropRotate,
  filters,
  watermark,
}

class Tool {
  final ToolId id;
  final String name;
  final String description;
  final String emoji;
  final ToolCategory category;

  const Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
  });
}

class ToolRegistry {
  static const List<Tool> all = [
    Tool(
      id: ToolId.compress,
      name: 'Compress',
      description: 'Shrink file size by quality or a target KB',
      emoji: '🗜️',
      category: ToolCategory.optimize,
    ),
    Tool(
      id: ToolId.resize,
      name: 'Resize',
      description: 'Change dimensions by %, exact size or presets',
      emoji: '📐',
      category: ToolCategory.optimize,
    ),
    Tool(
      id: ToolId.convert,
      name: 'Convert',
      description: 'JPEG · PNG · WebP conversion',
      emoji: '🔄',
      category: ToolCategory.optimize,
    ),
    Tool(
      id: ToolId.cropRotate,
      name: 'Crop & Rotate',
      description: 'Crop, straighten, rotate and flip',
      emoji: '✂️',
      category: ToolCategory.edit,
    ),
    Tool(
      id: ToolId.filters,
      name: 'Filters & Adjust',
      description: 'Presets plus brightness, contrast, saturation',
      emoji: '🎨',
      category: ToolCategory.edit,
    ),
    Tool(
      id: ToolId.watermark,
      name: 'Watermark',
      description: 'Stamp text over one or many images',
      emoji: '💧',
      category: ToolCategory.create,
    ),
  ];

  static Tool byId(ToolId id) => all.firstWhere((t) => t.id == id);

  static List<Tool> byCategory(ToolCategory c) =>
      all.where((t) => t.category == c).toList();
}
