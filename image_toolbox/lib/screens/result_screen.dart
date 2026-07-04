import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/enums.dart';
import '../models/image_job.dart';
import '../services/export_service.dart';
import '../services/gallery_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/glass_card.dart';

class ResultScreen extends StatelessWidget {
  final ImageJob job;
  const ResultScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final result = job.result!;
    final saved = result.savedBytes;
    final savedPositive = saved > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                BeforeAfterSlider(
                  before: job.sourceBytes,
                  after: result.bytes,
                ),
                const SizedBox(height: 20),
                GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _stat('Original',
                            Formatters.bytes(result.originalBytes),
                            AppColors.textSecondary),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.textMuted),
                      Expanded(
                        child: _stat('New', Formatters.bytes(result.newBytes),
                            AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  borderColor: (savedPositive ? AppColors.success : AppColors.accent)
                      .withValues(alpha: 0.5),
                  child: Row(
                    children: [
                      Icon(savedPositive ? Icons.trending_down : Icons.info,
                          color: savedPositive
                              ? AppColors.success
                              : AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          savedPositive
                              ? 'Saved ${Formatters.bytes(saved)} (${Formatters.percent(result.savedPercent)})'
                              : 'File is ${Formatters.bytes(-saved)} larger — try lower quality',
                          style: AppTheme.subtitle
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${Formatters.dimensions(result.width, result.height)}  ·  ${result.format.label}',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
                if (result.targetMissed) ...[
                  const SizedBox(height: 8),
                  Text('Could not fully reach the target size.',
                      style: AppTheme.body.copyWith(color: AppColors.accent),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(Icons.download, 'SAVE', AppColors.primary,
                          () => _save(context)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionBtn(Icons.share, 'SHARE',
                          AppColors.secondary, () => _share(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final result = job.result!;
    final ok = await GalleryService()
        .saveToGallery(result.bytes, result.suggestedName);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Saved to gallery' : 'Could not save')));
    }
  }

  Future<void> _share(BuildContext context) async {
    final result = job.result!;
    await ExportService().shareBytes(result.bytes, result.suggestedName,
        text: 'Processed with Image Toolbox');
  }

  Widget _stat(String label, String value, Color color) => Column(
        children: [
          Text(label, style: AppTheme.label),
          const SizedBox(height: 4),
          Text(value,
              style: AppTheme.subtitle
                  .copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      );

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.15),
          foregroundColor: color,
          elevation: 0,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label,
            style: AppTheme.body
                .copyWith(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
