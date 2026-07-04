import 'dart:math';
import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

/// A glowing, gently pulsing orb that represents an aura.
class AuraOrb extends StatefulWidget {
  final List<Color> colors;
  final double size;
  final String? emoji;
  final bool pulsing;

  const AuraOrb({
    super.key,
    required this.colors,
    this.size = 200,
    this.emoji,
    this.pulsing = true,
  });

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _AuraOrbState extends State<AuraOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.pulsing && FeedbackService().animationsEnabled) {
      _controller.repeat(reverse: true);
    }
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
        final pulse = 0.9 + 0.1 * sin(_controller.value * 2 * pi);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.colors.first,
                widget.colors.last,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withValues(alpha: 0.55 * pulse),
                blurRadius: 60 * pulse,
                spreadRadius: 12 * pulse,
              ),
              BoxShadow(
                color: widget.colors.last.withValues(alpha: 0.35 * pulse),
                blurRadius: 100 * pulse,
                spreadRadius: 4 * pulse,
              ),
            ],
          ),
          child: Center(
            child: widget.emoji != null
                ? Text(
                    widget.emoji!,
                    style: TextStyle(fontSize: widget.size * 0.4),
                  )
                : null,
          ),
        );
      },
    );
  }
}
