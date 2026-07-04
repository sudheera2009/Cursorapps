import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../models/enums.dart';
import '../models/recipe.dart';

/// Stores reusable processing recipes, seeded with a few useful defaults.
class RecipesProvider extends ChangeNotifier {
  final List<Recipe> _recipes = [];
  final _uuid = const Uuid();

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  RecipesProvider() {
    _load();
  }

  static List<Recipe> get _defaults => [
        Recipe(
          id: 'builtin_web',
          name: 'Web Ready',
          emoji: '🌐',
          ops: const [ResizeOp(mode: ResizeMode.maxDimension, maxDim: 1600)],
          encode: const EncodeSettings(
              format: OutputFormat.jpeg, quality: 82, targetSizeKb: 300),
        ),
        Recipe(
          id: 'builtin_email',
          name: 'Email Small',
          emoji: '✉️',
          ops: const [ResizeOp(mode: ResizeMode.maxDimension, maxDim: 1024)],
          encode: const EncodeSettings(
              format: OutputFormat.jpeg, targetSizeKb: 150),
        ),
        Recipe(
          id: 'builtin_insta',
          name: 'Instagram Square',
          emoji: '📸',
          ops: const [ResizeOp(mode: ResizeMode.exact, width: 1080, height: 1080)],
          encode: const EncodeSettings(format: OutputFormat.jpeg, quality: 90),
        ),
        Recipe(
          id: 'builtin_thumb',
          name: 'Tiny Thumbnail',
          emoji: '🔻',
          ops: const [ResizeOp(mode: ResizeMode.maxDimension, maxDim: 320)],
          encode: const EncodeSettings(format: OutputFormat.webp, quality: 80),
        ),
      ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('recipes');
    _recipes.clear();
    if (stored == null) {
      _recipes.addAll(_defaults);
      await _save();
    } else {
      try {
        _recipes.addAll(Recipe.decodeList(stored));
      } catch (_) {
        _recipes.addAll(_defaults);
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recipes', Recipe.encodeList(_recipes));
  }

  Future<void> add({
    required String name,
    required String emoji,
    required List<EditOp> ops,
    required EncodeSettings encode,
  }) async {
    _recipes.add(Recipe(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      ops: ops,
      encode: encode,
    ));
    await _save();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    await _save();
    notifyListeners();
  }
}
