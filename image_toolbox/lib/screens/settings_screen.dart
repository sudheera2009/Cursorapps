import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/enums.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Settings', style: AppTheme.headline),
          const SizedBox(height: 20),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEFAULT FORMAT', style: AppTheme.label),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: OutputFormat.values.map((f) {
                    final selected = s.defaultFormat == f;
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: selected,
                      showCheckmark: false,
                      backgroundColor: AppColors.surfaceAlt,
                      selectedColor: AppColors.primary,
                      labelStyle: AppTheme.body.copyWith(
                        color: selected ? Colors.black : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => s.setDefaultFormat(f),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('DEFAULT QUALITY · ${s.defaultQuality}',
                    style: AppTheme.label),
                Slider(
                  value: s.defaultQuality.toDouble(),
                  min: 10,
                  max: 100,
                  onChanged: (v) => s.setDefaultQuality(v.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: Text('Save to gallery', style: AppTheme.subtitle),
                  subtitle: Text('Auto-save results to the Image Toolbox album',
                      style: AppTheme.body),
                  value: s.saveToGallery,
                  onChanged: s.setSaveToGallery,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.primary,
                  title: Text('Keep EXIF metadata', style: AppTheme.subtitle),
                  subtitle: Text('Preserve camera/location data when possible',
                      style: AppTheme.body),
                  value: s.keepExif,
                  onChanged: s.setKeepExif,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            onTap: () => _confirmReset(context, s),
            child: Row(
              children: [
                const Icon(Icons.restart_alt, color: AppColors.danger),
                const SizedBox(width: 12),
                Text('Reset saved-space stats',
                    style: AppTheme.subtitle.copyWith(color: AppColors.danger)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Image Toolbox · v1.0.0',
                style: AppTheme.body.copyWith(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, SettingsProvider s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reset stats?', style: AppTheme.title),
        content: Text('This clears your lifetime saved-space totals.',
            style: AppTheme.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await s.resetStats();
  }
}
