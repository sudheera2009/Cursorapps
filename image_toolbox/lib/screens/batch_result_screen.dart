import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../models/enums.dart';
import '../providers/jobs_provider.dart';
import '../services/export_service.dart';
import '../services/gallery_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/glass_card.dart';

class BatchResultScreen extends StatelessWidget {
  const BatchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>();
    final done = jobs.done;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              borderColor: AppColors.success.withValues(alpha: 0.5),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 34),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${done.length} images processed',
                            style: AppTheme.subtitle
                                .copyWith(color: AppColors.textPrimary)),
                        Text(
                            'Saved ${Formatters.bytes(jobs.totalSavedBytes)} total',
                            style: AppTheme.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: jobs.jobs.length,
              itemBuilder: (context, i) {
                final job = jobs.jobs[i];
                final r = job.result;
                final ok = job.status == JobStatus.done && r != null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            r?.bytes ?? job.sourceBytes,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.sourcePath,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.body
                                      .copyWith(color: AppColors.textPrimary)),
                              if (ok)
                                Text(
                                    '${Formatters.bytes(r.originalBytes)} → ${Formatters.bytes(r.newBytes)}',
                                    style: AppTheme.body.copyWith(fontSize: 12))
                              else
                                Text('Failed',
                                    style: AppTheme.body
                                        .copyWith(color: AppColors.danger)),
                            ],
                          ),
                        ),
                        if (ok)
                          Text(Formatters.percent(r.savedPercent),
                              style: AppTheme.subtitle.copyWith(
                                  color: r.savedBytes > 0
                                      ? AppColors.success
                                      : AppColors.accent)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _saveAll(context, jobs),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      icon: const Icon(Icons.download, color: AppColors.primary),
                      label: Text('SAVE ALL',
                          style: AppTheme.body
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ExportService().exportZip(done),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.folder_zip),
                      label: const Text('EXPORT ZIP'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Future<void> _saveAll(BuildContext context, JobsProvider jobs) async {
    int saved = 0;
    for (final j in jobs.done) {
      final r = j.result;
      if (r == null) continue;
      final ok = await GalleryService().saveToGallery(r.bytes, r.suggestedName);
      if (ok) saved++;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved $saved images to gallery')));
    }
  }
}
