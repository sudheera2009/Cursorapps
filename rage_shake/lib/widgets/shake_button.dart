import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class ShakeButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final bool isActive;

  const ShakeButton({
    super.key,
    required this.onPressed,
    this.size = 200,
    this.isActive = false,
  });

  @override
  State<ShakeButton> createState() => _ShakeButtonState();
}

class _ShakeButtonState extends State<ShakeButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _particleController;
  final List<OrbitParticle> _particles = [];
  final Random _random = Random();
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateParticles);
    _particleController.repeat();

    _initParticles();
  }

  void _initParticles() {
    for (int i = 0; i < 12; i++) {
      _particles.add(OrbitParticle(
        angle: i * (2 * pi / 12),
        radius: widget.size / 2 + 20,
        speed: 0.01 + _random.nextDouble() * 0.02,
        size: 3 + _random.nextDouble() * 4,
      ));
    }
  }

  void _updateParticles() {
    setState(() {
      for (var particle in _particles) {
        particle.angle += particle.speed;
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _rotateController]),
      builder: (context, child) {
        final pulse = _pulseController.value;
        final rotation = _rotateController.value * 2 * pi;

        return SizedBox(
          width: widget.size + 60,
          height: widget.size + 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ..._particles.map((particle) {
                final x = cos(particle.angle + rotation * 0.5) * particle.radius;
                final y = sin(particle.angle + rotation * 0.5) * particle.radius;
                return Positioned(
                  left: widget.size / 2 + 30 + x - particle.size / 2,
                  top: widget.size / 2 + 30 + y - particle.size / 2,
                  child: Container(
                    width: particle.size,
                    height: particle.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: RageColors.primary[RageLevel.heated]!
                          .withOpacity(0.6 + pulse * 0.4),
                      boxShadow: [
                        BoxShadow(
                          color: RageColors.primary[RageLevel.heated]!
                              .withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Transform.rotate(
                angle: rotation * 0.2,
                child: Container(
                  width: widget.size + 30,
                  height: widget.size + 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RageColors.primary[RageLevel.heated]!
                          .withOpacity(0.3 + pulse * 0.2),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: -rotation * 0.3,
                child: Container(
                  width: widget.size + 15,
                  height: widget.size + 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: RageColors.primary[RageLevel.furious]!
                          .withOpacity(0.2 + pulse * 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  widget.onPressed();
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0 + pulse * 0.03,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          RageColors.primary[RageLevel.furious]!,
                          RageColors.primary[RageLevel.heated]!,
                          const Color(0xFF1A0A0A),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: RageColors.primary[RageLevel.furious]!
                              .withOpacity(0.5 + pulse * 0.3),
                          blurRadius: 30 + pulse * 20,
                          spreadRadius: 5 + pulse * 5,
                        ),
                        BoxShadow(
                          color: RageColors.primary[RageLevel.heated]!
                              .withOpacity(0.3),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SHAKE',
                          style: AppTheme.headlineStyle.copyWith(
                            fontSize: widget.size * 0.18,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.whatshot,
                          color: Colors.white,
                          size: widget.size * 0.2,
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.2, 1.2),
                              duration: 500.ms,
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrbitParticle {
  double angle;
  final double radius;
  final double speed;
  final double size;

  OrbitParticle({
    required this.angle,
    required this.radius,
    required this.speed,
    required this.size,
  });
}

class MiniShakeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color? color;
  final double width;

  const MiniShakeButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.color,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? RageColors.primary[RageLevel.heated]!;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              buttonColor,
              buttonColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: AppTheme.titleStyle.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.2));
  }
}
