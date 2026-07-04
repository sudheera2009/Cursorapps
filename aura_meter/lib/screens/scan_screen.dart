import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/aura_reading.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/aura_background.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scanController;
  late final AnimationController _ringController;
  bool _scanning = false;
  bool _completed = false;

  static const _statuses = [
    'PLACE FINGER TO SCAN',
    'READING ENERGY FIELD…',
    'ANALYZING YOUR VIBE…',
    'MEASURING CHAOS LEVELS…',
    'CALIBRATING AURA…',
    'ALMOST THERE…',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      });
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  void _startScan() {
    if (_completed) return;
    setState(() => _scanning = true);
    FeedbackService().scanPulse();
    _scanController.forward();
  }

  void _cancelScan() {
    if (_completed) return;
    if (_scanController.isCompleted) return;
    setState(() => _scanning = false);
    _scanController.reverse();
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    final provider = context.read<AuraProvider>();
    final AuraReading reading = provider.generateReading();
    provider.commitReading(reading);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultScreen(reading: reading),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  int get _statusIndex {
    final v = _scanController.value;
    if (!_scanning && v == 0) return 0;
    return (1 + (v * (_statuses.length - 1))).clamp(1, _statuses.length - 1).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AuraBackground(
        tint: AppColors.secondary,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: Listenable.merge([_scanController, _ringController]),
                builder: (context, _) {
                  return GestureDetector(
                    onTapDown: (_) => _startScan(),
                    onTapUp: (_) => _cancelScan(),
                    onTapCancel: _cancelScan,
                    child: _ScannerVisual(
                      progress: _scanController.value,
                      ringT: _ringController.value,
                      scanning: _scanning,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              AnimatedBuilder(
                animation: _scanController,
                builder: (context, _) {
                  return Text(
                    _statuses[_statusIndex],
                    style: AppTheme.subtitleStyle.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Hold your finger on the scanner',
                style: AppTheme.bodyStyle.copyWith(color: AppColors.textMuted),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerVisual extends StatelessWidget {
  final double progress;
  final double ringT;
  final bool scanning;

  const _ScannerVisual({
    required this.progress,
    required this.ringT,
    required this.scanning,
  });

  @override
  Widget build(BuildContext context) {
    const size = 240.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating outer rings.
          Transform.rotate(
            angle: ringT * 2 * pi,
            child: CustomPaint(
              size: const Size(size, size),
              painter: _RingPainter(progress: progress),
            ),
          ),
          // Progress ring.
          SizedBox(
            width: size - 40,
            height: size - 40,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          // Core.
          Container(
            width: size - 90,
            height: size - 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: scanning ? 0.9 : 0.4),
                  AppColors.backgroundAlt,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary
                      .withValues(alpha: scanning ? 0.6 : 0.2),
                  blurRadius: scanning ? 40 : 16,
                  spreadRadius: scanning ? 6 : 2,
                ),
              ],
            ),
            child: Icon(
              Icons.fingerprint,
              size: 72,
              color: Colors.white.withValues(alpha: scanning ? 1 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.secondary.withValues(alpha: 0.35);
    // Dashed arcs to give a "targeting" feel.
    for (int i = 0; i < 12; i++) {
      final start = (i / 12) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2 - 4),
        start,
        0.28,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
