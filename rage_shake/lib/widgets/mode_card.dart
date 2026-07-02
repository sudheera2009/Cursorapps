import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/destruction_mode.dart';
import '../core/theme.dart';
import 'glass_card.dart';

class ModeCard extends StatefulWidget {
  final DestructionMode mode;
  final int userLevel;
  final int? highScore;
  final bool isSelected;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.userLevel,
    this.highScore,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  bool _isHovered = false;

  bool get isUnlocked => widget.mode.isUnlocked(widget.userLevel);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isUnlocked ? widget.onTap : _showLockedMessage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_isHovered ? -0.02 : 0)
            ..rotateY(_isHovered ? 0.02 : 0)
            ..scale(widget.isSelected ? 1.05 : (_isHovered ? 1.02 : 1.0)),
          child: GlassCard(
            glowColor: widget.isSelected ? widget.mode.color : null,
            showCracks: widget.isSelected,
            crackIntensity: widget.isSelected ? 0.3 : 0,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.mode.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.mode.color.withOpacity(0.5),
                            ),
                          ),
                          child: Icon(
                            widget.mode.icon,
                            color: isUnlocked
                                ? widget.mode.color
                                : Colors.grey,
                            size: 32,
                          ),
                        )
                            .animate(
                              onPlay: (c) => c.repeat(reverse: true),
                            )
                            .rotate(
                              begin: -0.02,
                              end: 0.02,
                              duration: 2.seconds,
                            ),
                        const Spacer(),
                        if (!isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lvl ${widget.mode.requiredLevel}',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.mode.name,
                      style: AppTheme.titleStyle.copyWith(
                        color: isUnlocked ? Colors.white : Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.highScore != null && widget.highScore! > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatScore(widget.highScore!),
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'No record yet',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reach level ${widget.mode.requiredLevel} to unlock ${widget.mode.name}!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.cardBackground,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000000) {
      return '\$${(score / 1000000000).toStringAsFixed(1)}B';
    } else if (score >= 1000000) {
      return '\$${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '\$${(score / 1000).toStringAsFixed(1)}K';
    }
    return '\$$score';
  }
}

class ModeDetailPanel extends StatelessWidget {
  final DestructionMode mode;
  final VoidCallback onStart;

  const ModeDetailPanel({
    super.key,
    required this.mode,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: mode.color,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(mode.icon, color: mode.color, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  mode.name,
                  style: AppTheme.titleStyle.copyWith(
                    color: mode.color,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            mode.description,
            style: AppTheme.bodyStyle,
          ),
          const SizedBox(height: 20),
          Text(
            'Destructibles:',
            style: AppTheme.subtitleStyle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mode.objects.take(4).map((obj) {
              return Chip(
                avatar: Icon(obj.icon, size: 16, color: mode.color),
                label: Text(
                  obj.name,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: mode.color.withOpacity(0.1),
                side: BorderSide(color: mode.color.withOpacity(0.3)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: mode.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow),
                  const SizedBox(width: 8),
                  Text(
                    'START DESTRUCTION',
                    style: AppTheme.titleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.whatshot),
                ],
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}
