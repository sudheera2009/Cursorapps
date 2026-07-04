import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../providers/jobs_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ad_service.dart';
import 'batch_result_screen.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final List<EditOp> ops;
  final EncodeSettings encode;

  const ProcessingScreen({super.key, required this.ops, required this.encode});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final jobs = context.read<JobsProvider>();
    final settings = context.read<SettingsProvider>();

    await jobs.runAll(
      ops: widget.ops,
      encode: widget.encode,
      onJobDone: (job) {
        final r = job.result;
        if (r != null) settings.recordProcessed(savedBytes: r.savedBytes);
      },
    );

    if (!mounted) return;
    final done = jobs.done;

    void goToResult() {
      if (!mounted) return;
      if (done.length == 1) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ResultScreen(job: done.first)));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const BatchResultScreen()));
      }
    }

    // Show an interstitial for larger batches before revealing results.
    if (jobs.total >= 3) {
      AdService().showInterstitialAd(onAdClosed: goToResult);
    } else {
      goToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobsProvider>();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 5),
              ),
              const SizedBox(height: 28),
              Text('Processing…', style: AppTheme.title),
              const SizedBox(height: 8),
              Text('${jobs.completed} of ${jobs.total}', style: AppTheme.body),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: jobs.total == 0 ? null : jobs.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
