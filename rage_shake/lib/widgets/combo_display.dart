import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';

class ComboDisplay extends StatelessWidget {
  final int combo;
  final bool isActive;

  const ComboDisplay({
    super.key,
    required this.combo,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (combo <= 1) return const SizedBox.shrink();

    final tier = _getComboTier(combo);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tier.color.withOpacity(0.3),
            tier.color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier.color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier.icon,
            color: tier.color,
            size: 24,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: Duration(milliseconds: _getPulseDuration(combo)),
              ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'x$combo',
                style: AppTheme.numberStyle.copyWith(
                  fontSize: _getFontSize(combo),
                  color: tier.color,
                  shadows: [
                    Shadow(
                      color: tier.color.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Text(
                tier.name,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 10,
                  color: tier.color.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(
          key: ValueKey(combo),
          onPlay: (c) => c.forward(),
        )
        .scale(
          begin: const Offset(1.3, 1.3),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.elasticOut,
        );
  }

  ComboTier _getComboTier(int combo) {
    if (combo >= 100) {
      return ComboTier(
        name: 'LEGENDARY',
        icon: Icons.auto_awesome,
        color: const Color(0xFFFFD700),
      );
    } else if (combo >= 75) {
      return ComboTier(
        name: 'EPIC',
        icon: Icons.diamond,
        color: const Color(0xFFE040FB),
      );
    } else if (combo >= 50) {
      return ComboTier(
        name: 'UNSTOPPABLE',
        icon: Icons.local_fire_department,
        color: const Color(0xFFFF5722),
      );
    } else if (combo >= 25) {
      return ComboTier(
        name: 'ON FIRE',
        icon: Icons.whatshot,
        color: const Color(0xFFFF9800),
      );
    } else if (combo >= 10) {
      return ComboTier(
        name: 'RAMPAGE',
        icon: Icons.bolt,
        color: const Color(0xFFFFEB3B),
      );
    } else {
      return ComboTier(
        name: 'COMBO',
        icon: Icons.flash_on,
        color: const Color(0xFF00E5FF),
      );
    }
  }

  double _getFontSize(int combo) {
    if (combo >= 100) return 32;
    if (combo >= 50) return 28;
    if (combo >= 25) return 24;
    return 20;
  }

  int _getPulseDuration(int combo) {
    if (combo >= 100) return 150;
    if (combo >= 50) return 200;
    if (combo >= 25) return 300;
    return 400;
  }
}

class ComboTier {
  final String name;
  final IconData icon;
  final Color color;

  ComboTier({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ComboBreakEffect extends StatefulWidget {
  final int lastCombo;
  final VoidCallback? onComplete;

  const ComboBreakEffect({
    super.key,
    required this.lastCombo,
    this.onComplete,
  });

  @override
  State<ComboBreakEffect> createState() => _ComboBreakEffectState();
}

class _ComboBreakEffectState extends State<ComboBreakEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
        return Opacity(
          opacity: 1 - _controller.value,
          child: Transform.scale(
            scale: 1 + _controller.value * 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                'COMBO BREAK!',
                style: AppTheme.titleStyle.copyWith(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ComboMilestone extends StatelessWidget {
  final int combo;

  const ComboMilestone({super.key, required this.combo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${combo}x COMBO!',
                style: AppTheme.titleStyle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Text(
                'Milestone Reached!',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shimmer(duration: 1.seconds, color: Colors.white.withOpacity(0.3))
        .then(delay: 1.seconds)
        .fadeOut(duration: 500.ms)
        .slideY(end: -0.5);
  }
}
