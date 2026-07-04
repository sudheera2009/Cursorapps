import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/feedback_service.dart';

/// Animated cosmic background: drifting stars plus a couple of slow-moving
/// nebula blobs tinted by [tint].
class AuraBackground extends StatefulWidget {
  final Color tint;
  final bool animate;
  final Widget child;

  const AuraBackground({
    super.key,
    required this.child,
    this.tint = AppColors.primary,
    this.animate = true,
  });

  @override
  State<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends State<AuraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rnd = Random(7);
    _stars = List.generate(60, (_) {
      return _Star(
        pos: Offset(rnd.nextDouble(), rnd.nextDouble()),
        radius: 0.5 + rnd.nextDouble() * 1.8,
        phase: rnd.nextDouble(),
        speed: 0.3 + rnd.nextDouble(),
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.animate && FeedbackService().animationsEnabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.spaceGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _AuraPainter(
                    t: _controller.value,
                    stars: _stars,
                    tint: widget.tint,
                  ),
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Star {
  final Offset pos;
  final double radius;
  final double phase;
  final double speed;
  _Star({
    required this.pos,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

class _AuraPainter extends CustomPainter {
  final double t;
  final List<_Star> stars;
  final Color tint;

  _AuraPainter({required this.t, required this.stars, required this.tint});

  @override
  void paint(Canvas canvas, Size size) {
    // Nebula blobs.
    final blob1 = Offset(
      size.width * (0.25 + 0.1 * sin(t * 2 * pi)),
      size.height * (0.28 + 0.06 * cos(t * 2 * pi)),
    );
    final blob2 = Offset(
      size.width * (0.78 + 0.08 * cos(t * 2 * pi)),
      size.height * (0.7 + 0.07 * sin(t * 2 * pi)),
    );
    _paintBlob(canvas, blob1, size.width * 0.55, tint.withValues(alpha: 0.20));
    _paintBlob(
        canvas, blob2, size.width * 0.5, AppColors.secondary.withValues(alpha: 0.12));

    // Twinkling stars.
    final starPaint = Paint()..color = Colors.white;
    for (final s in stars) {
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * sin((t * s.speed + s.phase) * 2 * pi));
      starPaint.color = Colors.white.withValues(alpha: 0.5 * twinkle);
      canvas.drawCircle(
        Offset(s.pos.dx * size.width, s.pos.dy * size.height),
        s.radius,
        starPaint,
      );
    }
  }

  void _paintBlob(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuraPainter old) =>
      old.t != t || old.tint != tint;
}
