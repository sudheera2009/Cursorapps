import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final avgPerFile =
        s.filesProcessed == 0 ? 0 : s.bytesSaved ~/ s.filesProcessed;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Your Impact', style: AppTheme.headline),
          const SizedBox(height: 4),
          Text('Everything processed on-device, privately', style: AppTheme.body),
          const SizedBox(height: 20),
          GlassCard(
            padding: const EdgeInsets.all(24),
            borderColor: AppColors.primary.withValues(alpha: 0.5),
            child: Column(
              children: [
                const Icon(Icons.cloud_done, color: AppColors.primary, size: 44),
                const SizedBox(height: 12),
                Text('TOTAL SPACE SAVED', style: AppTheme.label),
                const SizedBox(height: 6),
                Text(Formatters.bytes(s.bytesSaved),
                    style: AppTheme.number.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metric('Images', '${s.filesProcessed}',
                    Icons.image, AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metric('Avg / image', Formatters.bytes(avgPerFile),
                    Icons.compress, AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRIVACY FIRST', style: AppTheme.label),
                const SizedBox(height: 8),
                Text(
                  'Image Toolbox never uploads your photos. Every compression, '
                  'resize and edit happens entirely on your device.',
                  style: AppTheme.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: AppTheme.title.copyWith(color: AppColors.textPrimary)),
          Text(label, style: AppTheme.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
