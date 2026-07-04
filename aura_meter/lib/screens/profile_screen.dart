import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_orb.dart';
import '../widgets/glass_card.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, provider, _) {
        final p = provider.profile;
        final signature = provider.dailyAura;
        return Scaffold(
          appBar: AppBar(
            title: Text('PROFILE', style: AppTheme.titleStyle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  FeedbackService().tap();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: AuraBackground(
            tint: signature.color,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Center(
                    child: Column(
                      children: [
                        AuraOrb(
                            colors: signature.gradient,
                            size: 120,
                            emoji: signature.emoji),
                        const SizedBox(height: 16),
                        Text('AURA LEVEL ${p.level}',
                            style: AppTheme.headlineStyle),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 220,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: p.levelProgress,
                              minHeight: 8,
                              backgroundColor: AppColors.cardBorder,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${5 - (p.totalScans % 5)} scans to next level',
                            style: AppTheme.labelStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    children: [
                      _stat('⭐', 'Aura Points', '${p.auraPoints}'),
                      _stat('🔮', 'Total Scans', '${p.totalScans}'),
                      _stat('🏆', 'Best Score', '${p.bestScore}'),
                      _stat('🔥', 'Day Streak', '${p.dailyStreak}'),
                      _stat('⚔️', 'Duels Won', '${p.duelsWon}'),
                      _stat('📊', 'Win Rate', '${p.winRate}%'),
                      _stat('🌈', 'Auras Found', '${p.discoveredAuras.length}/10'),
                      _stat('🎖️', 'Awards',
                          '${p.unlockedAchievements.length}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        FeedbackService().tap();
                        ShareService().shareText(
                          'My AURA METER stats 🔮\n'
                          'Level ${p.level} • Best ${p.bestScore} aura\n'
                          '${p.discoveredAuras.length}/10 auras collected • '
                          '${p.duelsWon} duels won\n'
                          'Scan yours! #AuraMeter',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.share),
                      label: Text('SHARE MY STATS',
                          style: AppTheme.subtitleStyle.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String emoji, String label, String value) => GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: AppTheme.subtitleStyle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  Text(label, style: AppTheme.labelStyle, maxLines: 1),
                ],
              ),
            ),
          ],
        ),
      );
}
