import 'dart:convert';

import 'edit_op.dart';
import 'encode_settings.dart';

/// A named, reusable chain of edit operations plus encode settings.
class Recipe {
  final String id;
  final String name;
  final String emoji;
  final List<EditOp> ops;
  final EncodeSettings encode;

  const Recipe({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ops,
    required this.encode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'ops': ops.map((o) => o.toJson()).toList(),
        'encode': encode.toJson(),
      };

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String? ?? '⚙️',
        ops: (j['ops'] as List<dynamic>)
            .map((e) => EditOp.fromJson(e as Map<String, dynamic>))
            .toList(),
        encode:
            EncodeSettings.fromJson(j['encode'] as Map<String, dynamic>? ?? {}),
      );

  static String encodeList(List<Recipe> recipes) =>
      json.encode(recipes.map((r) => r.toJson()).toList());

  static List<Recipe> decodeList(String source) {
    final List<dynamic> decoded = json.decode(source);
    return decoded
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
