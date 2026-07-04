import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/edit_op.dart';
import '../models/encode_settings.dart';
import '../pipeline/image_pipeline.dart';

/// Renders a debounced, on-device preview of the current ops + encode settings
/// applied to a small proxy image, so users see the effect before committing.
class LivePreview extends StatefulWidget {
  final Uint8List? proxyBytes;
  final List<EditOp> ops;
  final EncodeSettings encode;

  const LivePreview({
    super.key,
    required this.proxyBytes,
    required this.ops,
    required this.encode,
  });

  @override
  State<LivePreview> createState() => _LivePreviewState();
}

class _LivePreviewState extends State<LivePreview> {
  Timer? _debounce;
  Uint8List? _preview;
  bool _busy = false;
  int _token = 0;

  @override
  void didUpdateWidget(covariant LivePreview old) {
    super.didUpdateWidget(old);
    if (widget.proxyBytes != null &&
        (old.proxyBytes != widget.proxyBytes ||
            _configString(old) != _configString(widget))) {
      _schedule();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.proxyBytes != null) _schedule(immediate: true);
  }

  String _configString(LivePreview w) =>
      '${w.ops.map((o) => o.toJson()).toList()}|${w.encode.toJson()}';

  void _schedule({bool immediate = false}) {
    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: immediate ? 0 : 300),
      _recompute,
    );
  }

  Future<void> _recompute() async {
    final proxy = widget.proxyBytes;
    if (proxy == null) return;
    final token = ++_token;
    setState(() => _busy = true);
    try {
      final result = await ImagePipeline().process(
        bytes: proxy,
        sourceName: 'preview.png',
        ops: widget.ops,
        encode: widget.encode,
      );
      if (!mounted || token != _token) return;
      setState(() {
        _preview = result.bytes;
        _busy = false;
      });
    } catch (_) {
      if (!mounted || token != _token) return;
      setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _preview ?? widget.proxyBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 240,
        width: double.infinity,
        color: AppColors.surfaceAlt,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.memory(image, fit: BoxFit.contain, gaplessPlayback: true)
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            if (_busy)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LIVE PREVIEW', style: AppTheme.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
