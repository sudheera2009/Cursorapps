import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/tool.dart';
import 'glass_card.dart';

class ToolCard extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;

  const ToolCard({super.key, required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tool.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text(tool.name,
              style: AppTheme.subtitle.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            tool.description,
            style: AppTheme.body.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
