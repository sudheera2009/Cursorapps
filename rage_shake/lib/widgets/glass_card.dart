import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final Color? glowColor;
  final bool showCracks;
  final double crackIntensity;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 20,
    this.glowColor,
    this.showCracks = false,
    this.crackIntensity = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: AppTheme.cardBackground.withOpacity(0.6),
                border: Border.all(
                  color: glowColor?.withOpacity(0.5) ?? AppTheme.cardBorder,
                  width: 1.5,
                ),
                boxShadow: glowColor != null
                    ? [
                        BoxShadow(
                          color: glowColor!.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  if (showCracks && crackIntensity > 0)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CrackPainter(
                          intensity: crackIntensity,
                          color: glowColor ?? Colors.white,
                        ),
                      ),
                    ),
                  Padding(
                    padding: padding,
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 3.seconds,
          color: (glowColor ?? Colors.white).withOpacity(0.1),
        );
  }
}

class CrackPainter extends CustomPainter {
  final double intensity;
  final Color color;

  CrackPainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity(intensity * 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final crackCount = (intensity * 5).toInt();
    
    for (int i = 0; i < crackCount; i++) {
      final startX = size.width * (0.2 + i * 0.15);
      final startY = 0.0;
      
      final path = Path();
      path.moveTo(startX, startY);
      
      double currentX = startX;
      double currentY = startY;
      
      while (currentY < size.height) {
        final nextX = currentX + (i.isEven ? 10 : -10) * intensity;
        final nextY = currentY + 20 + 10 * intensity;
        path.lineTo(nextX.clamp(0, size.width), nextY);
        currentX = nextX;
        currentY = nextY;
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CrackPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

class GlowingBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final double glowIntensity;

  const GlowingBorder({
    super.key,
    required this.child,
    required this.color,
    this.borderRadius = 20,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4 * glowIntensity),
            blurRadius: 15 * glowIntensity,
            spreadRadius: 2 * glowIntensity,
          ),
          BoxShadow(
            color: color.withOpacity(0.2 * glowIntensity),
            blurRadius: 30 * glowIntensity,
            spreadRadius: 5 * glowIntensity,
          ),
        ],
      ),
      child: child,
    );
  }
}
