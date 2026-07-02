import 'dart:math';
import 'package:flutter/material.dart';
import '../providers/game_provider.dart';
import '../core/theme.dart';

class ParticleOverlay extends StatelessWidget {
  final List<Particle> particles;
  final List<FloatingDamage> damages;
  final double rageLevel;

  const ParticleOverlay({
    super.key,
    required this.particles,
    required this.damages,
    required this.rageLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (rageLevel > 0.6)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: EdgeFlamePainter(
                  intensity: (rageLevel - 0.6) / 0.4,
                  color: RageColors.lerpPrimary(rageLevel),
                ),
              ),
            ),
          ),
        CustomPaint(
          painter: ParticlePainter(particles: particles),
          size: Size.infinite,
        ),
        ...damages.map((damage) => Positioned(
              left: damage.position.dx - 50,
              top: damage.position.dy + damage.offsetY,
              child: SizedBox(
                width: 100,
                child: DamageNumber(damage: damage),
              ),
            )),
      ],
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size * particle.opacity,
        paint,
      );

      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        particle.position,
        particle.size * 2 * particle.opacity,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class DamageNumber extends StatelessWidget {
  final FloatingDamage damage;

  const DamageNumber({super.key, required this.damage});

  @override
  Widget build(BuildContext context) {
    final color = _getColorForDamage(damage.damage);

    return Opacity(
      opacity: damage.opacity,
      child: Transform.scale(
        scale: 0.8 + damage.opacity * 0.4,
        child: Text(
          damage.formattedDamage,
          textAlign: TextAlign.center,
          style: AppTheme.damageStyle.copyWith(
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.8),
                blurRadius: 10,
              ),
              const Shadow(
                color: Colors.black,
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForDamage(int damage) {
    if (damage >= 1000000) return const Color(0xFFFFD700);
    if (damage >= 100000) return const Color(0xFFFF4444);
    if (damage >= 10000) return const Color(0xFFFF9800);
    if (damage >= 1000) return const Color(0xFFFFEB3B);
    return Colors.white;
  }
}

class EdgeFlamePainter extends CustomPainter {
  final double intensity;
  final Color color;

  EdgeFlamePainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.transparent,
          Colors.transparent,
          color.withOpacity(intensity * 0.3),
          color.withOpacity(intensity * 0.6),
        ],
        stops: const [0.0, 0.7, 0.9, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final flamePaint = Paint()
      ..color = color.withOpacity(intensity * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 50 * intensity, size.width, 50 * intensity),
      flamePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 30 * intensity),
      flamePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 30 * intensity, size.height),
      flamePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width - 30 * intensity, 0, 30 * intensity, size.height),
      flamePaint,
    );
  }

  @override
  bool shouldRepaint(covariant EdgeFlamePainter oldDelegate) {
    return oldDelegate.intensity != intensity || oldDelegate.color != color;
  }
}

class ExplosionEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const ExplosionEffect({
    super.key,
    required this.position,
    required this.color,
    this.size = 100,
    this.onComplete,
  });

  @override
  State<ExplosionEffect> createState() => _ExplosionEffectState();
}

class _ExplosionEffectState extends State<ExplosionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - widget.size / 2,
          top: widget.position.dy - widget.size / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      widget.color,
                      widget.color.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScreenShake extends StatefulWidget {
  final Widget child;
  final double intensity;

  const ScreenShake({
    super.key,
    required this.child,
    required this.intensity,
  });

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.intensity < 0.1) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offsetX = (_random.nextDouble() - 0.5) * widget.intensity * 10;
        final offsetY = (_random.nextDouble() - 0.5) * widget.intensity * 10;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: widget.child,
        );
      },
    );
  }
}
