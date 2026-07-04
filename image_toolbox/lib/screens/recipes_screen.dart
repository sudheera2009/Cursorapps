import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/enums.dart';
import '../models/recipe.dart';
import '../providers/recipes_provider.dart';
import '../widgets/glass_card.dart';
import 'tool_flow.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipesProvider>().recipes;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Recipes', style: AppTheme.headline),
          const SizedBox(height: 4),
          Text('One-tap presets for common jobs', style: AppTheme.body),
          const SizedBox(height: 20),
          ...recipes.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RecipeTile(recipe: r),
              )),
        ],
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  final Recipe recipe;
  const _RecipeTile({required this.recipe});

  String get _summary {
    final parts = <String>[];
    for (final op in recipe.ops) {
      if (op.type == 'resize') parts.add('resize');
      if (op.type == 'filter') parts.add('filter');
      if (op.type == 'watermark') parts.add('watermark');
    }
    parts.add(recipe.encode.format.label);
    if (recipe.encode.targetSizeKb != null) {
      parts.add('≤${recipe.encode.targetSizeKb}KB');
    } else if (recipe.encode.format.isLossy) {
      parts.add('q${recipe.encode.quality}');
    }
    return parts.join(' · ');
  }

  bool get _isBuiltin => recipe.id.startsWith('builtin_');

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => applyRecipe(context, recipe),
      child: Row(
        children: [
          Text(recipe.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name,
                    style: AppTheme.subtitle
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(_summary, style: AppTheme.body.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (!_isBuiltin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
              onPressed: () =>
                  context.read<RecipesProvider>().remove(recipe.id),
            )
          else
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
