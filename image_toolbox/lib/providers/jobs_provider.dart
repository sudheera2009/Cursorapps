import 'package:flutter/foundation.dart';

import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../models/enums.dart';
import '../models/image_job.dart';
import '../pipeline/image_pipeline.dart';

/// Holds the current image selection and runs the batch through the pipeline.
class JobsProvider extends ChangeNotifier {
  final List<ImageJob> _jobs = [];
  bool _processing = false;
  int _completed = 0;

  List<ImageJob> get jobs => List.unmodifiable(_jobs);
  bool get processing => _processing;
  bool get hasSelection => _jobs.isNotEmpty;
  int get completed => _completed;
  int get total => _jobs.length;

  double get progress => _jobs.isEmpty ? 0 : _completed / _jobs.length;

  List<ImageJob> get done =>
      _jobs.where((j) => j.status == JobStatus.done).toList();

  int get totalOriginalBytes =>
      done.fold(0, (sum, j) => sum + j.originalBytes);
  int get totalNewBytes =>
      done.fold(0, (sum, j) => sum + (j.result?.newBytes ?? 0));
  int get totalSavedBytes => totalOriginalBytes - totalNewBytes;

  void setSelection(List<ImageJob> jobs) {
    _jobs
      ..clear()
      ..addAll(jobs);
    _completed = 0;
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _jobs.length) {
      _jobs.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _jobs.clear();
    _completed = 0;
    _processing = false;
    notifyListeners();
  }

  /// Runs every queued job. [onJobDone] fires after each success with the saved
  /// byte delta so callers can update lifetime stats.
  Future<void> runAll({
    required List<EditOp> ops,
    required EncodeSettings encode,
    void Function(ImageJob job)? onJobDone,
  }) async {
    if (_processing) return;
    _processing = true;
    _completed = 0;
    for (final j in _jobs) {
      j.status = JobStatus.queued;
      j.result = null;
      j.error = null;
    }
    notifyListeners();

    for (int i = 0; i < _jobs.length; i++) {
      final job = _jobs[i];
      job.status = JobStatus.processing;
      notifyListeners();
      try {
        final result = await ImagePipeline().process(
          bytes: job.sourceBytes,
          sourceName: job.sourcePath,
          ops: ops,
          encode: encode,
          outputIndex: i,
        );
        job.result = result;
        job.status = JobStatus.done;
        onJobDone?.call(job);
      } catch (e) {
        job.status = JobStatus.error;
        job.error = e.toString();
        debugPrint('Job failed: $e');
      }
      _completed++;
      notifyListeners();
    }

    _processing = false;
    notifyListeners();
  }
}
