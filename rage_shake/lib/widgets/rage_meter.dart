import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class RageMeter extends StatefulWidget {
  final double rageLevel;
  final bool isVertical;
  final double height;
  final double width;

  const RageMeter({
    super.key,
    required this.rageLevel,
    this.isVertical = false,
    this.height = 30,
    this.width = double.infinity,
  });

  @override
  State<RageMeter> createState() => _RageMeterState();
}

class _RageMeterState extends State<RageMeter> with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _pulseController;
  final List<Bubble> _bubbles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateBubbles);
    _bubbleController.repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _updateBubbles() {
    setState(() {
      if (_random.nextDouble() < widget.rageLevel * 0.3) {
        _bubbles.add(Bubble(
          x: _random.nextDouble(),
          y: 1.0,
          size: 2 + _random.nextDouble() * 4,
          speed: 0.02 + _random.nextDouble() * 0.03 * (1 + widget.rageLevel),
        ));
      }

      for (var bubble in _bubbles) {
        bubble.y -= bubble.speed;
      }

      _bubbles.removeWhere((b) => b.y < 0);
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rageColor = RageColors.lerpPrimary(widget.rageLevel);
    final rageLevel = RageColors.getLevel(widget.rageLevel);
    final isNuclear = rageLevel == RageLevel.nuclear;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final glowIntensity = 0.5 + pulseValue * 0.5 * widget.rageLevel;

        return Container(
          height: widget.isVertical ? widget.height : widget.height,
          width: widget.isVertical ? widget.width : widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: rageColor.withOpacity(glowIntensity * 0.5),
                blurRadius: 15 * glowIntensity,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    border: Border.all(
                      color: rageColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: widget.isVertical
                      ? widget.width
                      : (widget.width == double.infinity
                          ? null
                          : widget.width * widget.rageLevel),
                  height: widget.isVertical
                      ? widget.height * widget.rageLevel
                      : widget.height,
                  alignment:
                      widget.isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: widget.isVertical ? constraints.maxWidth : constraints.maxWidth * widget.rageLevel,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.height / 2),
                          gradient: LinearGradient(
                            begin: widget.isVertical
                                ? Alignment.bottomCenter
                                : Alignment.centerLeft,
                            end: widget.isVertical
                                ? Alignment.topCenter
                                : Alignment.centerRight,
                            colors: [
                              rageColor.withOpacity(0.8),
                              rageColor,
                              isNuclear ? Colors.white : rageColor.withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: CustomPaint(
                          painter: BubblePainter(
                            bubbles: _bubbles,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (widget.rageLevel > 0.6)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FlamePainter(
                        intensity: (widget.rageLevel - 0.6) / 0.4,
                        color: rageColor,
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildRageIcon(rageLevel),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRageIcon(RageLevel level) {
    IconData icon;
    switch (level) {
      case RageLevel.calm:
        icon = Icons.sentiment_satisfied;
      case RageLevel.annoyed:
        icon = Icons.sentiment_neutral;
      case RageLevel.heated:
        icon = Icons.sentiment_dissatisfied;
      case RageLevel.furious:
        icon = Icons.sentiment_very_dissatisfied;
      case RageLevel.nuclear:
        icon = Icons.whatshot;
    }

    return Icon(
      icon,
      color: Colors.white,
      size: widget.height * 0.6,
    ).animate(
      onPlay: (c) => c.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: Offset(1 + widget.rageLevel * 0.2, 1 + widget.rageLevel * 0.2),
      duration: Duration(milliseconds: (500 - widget.rageLevel * 300).toInt().clamp(100, 500)),
    );
  }
}

class Bubble {
  double x;
  double y;
  final double size;
  final double speed;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final Color color;

  BubblePainter({required this.bubbles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      canvas.drawCircle(
        Offset(bubble.x * size.width, bubble.y * size.height),
        bubble.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}

class FlamePainter extends CustomPainter {
  final double intensity;
  final Color color;

  FlamePainter({required this.intensity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color.withOpacity(intensity * 0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height);

    final waveCount = 5;
    final waveWidth = size.width / waveCount;

    for (int i = 0; i <= waveCount; i++) {
      final x = i * waveWidth;
      final y = size.height - (size.height * 0.3 * intensity * (0.5 + 0.5 * sin(i * pi)));
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.quadraticBezierTo(
          x - waveWidth / 2,
          size.height - size.height * 0.5 * intensity,
          x,
          y,
        );
      }
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FlamePainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

class RageLevelIndicator extends StatelessWidget {
  final RageLevel level;

  const RageLevelIndicator({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = RageColors.getPrimary(level);
    final name = _getLevelName(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        name,
        style: AppTheme.subtitleStyle.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLevelName(RageLevel level) {
    switch (level) {
      case RageLevel.calm:
        return 'CALM';
      case RageLevel.annoyed:
        return 'ANNOYED';
      case RageLevel.heated:
        return 'HEATED';
      case RageLevel.furious:
        return 'FURIOUS';
      case RageLevel.nuclear:
        return '☢ NUCLEAR ☢';
    }
  }
}
