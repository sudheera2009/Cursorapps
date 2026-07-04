import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/achievement.dart';
import '../providers/aura_provider.dart';
import '../widgets/aura_background.dart';
import '../widgets/glass_card.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, provider, _) {
        final unlocked = provider.profile.unlockedAchievements.toSet();
        return Scaffold(
          appBar: AppBar(
            title: Text('AWARDS', style: AppTheme.titleStyle),
          ),
          extendBodyBehindAppBar: true,
          body: AuraBackground(
            tint: AppColors.gold,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    'UNLOCKED  ${unlocked.length}/${Achievements.all.length}',
                    style: AppTheme.labelStyle,
                  ),
                  const SizedBox(height: 12),
                  ...Achievements.all.map((a) {
                    final has = unlocked.contains(a.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        borderColor:
                            has ? AppColors.gold.withValues(alpha: 0.5) : null,
                        child: Row(
                          children: [
                            Opacity(
                              opacity: has ? 1 : 0.3,
                              child: Text(a.emoji,
                                  style: const TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.name,
                                      style: AppTheme.subtitleStyle.copyWith(
                                        color: has
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text(a.description,
                                      style: AppTheme.bodyStyle),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            has
                                ? const Icon(Icons.verified,
                                    color: AppColors.gold)
                                : Text('+${a.auraReward}',
                                    style: AppTheme.labelStyle
                                        .copyWith(color: AppColors.gold)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
