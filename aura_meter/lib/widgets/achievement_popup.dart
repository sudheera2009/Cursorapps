import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/achievement.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import 'glass_card.dart';

/// Shows a celebratory dialog for any achievements unlocked during the last
/// action, then clears them from the provider. Safe to call when none exist.
Future<void> showAchievementUnlocks(
  BuildContext context,
  AuraProvider provider,
) async {
  final unlocked = List<Achievement>.from(provider.newlyUnlocked);
  provider.clearNewlyUnlocked();
  if (unlocked.isEmpty) return;

  FeedbackService().reveal();
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (ctx) => _AchievementDialog(achievements: unlocked),
  );
}

class _AchievementDialog extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementDialog({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: GlassCard(
        borderColor: AppColors.gold.withValues(alpha: 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎖️', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(
              achievements.length > 1
                  ? 'ACHIEVEMENTS UNLOCKED'
                  : 'ACHIEVEMENT UNLOCKED',
              style: AppTheme.labelStyle.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: 16),
            ...achievements.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name,
                              style: AppTheme.subtitleStyle.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold)),
                          Text(a.description, style: AppTheme.bodyStyle),
                        ],
                      ),
                    ),
                    Text('+${a.auraReward}',
                        style: AppTheme.subtitleStyle
                            .copyWith(color: AppColors.gold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  FeedbackService().tap();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('NICE!',
                    style: AppTheme.subtitleStyle.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
