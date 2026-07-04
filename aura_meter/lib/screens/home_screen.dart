import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_orb.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/glass_card.dart';
import 'achievements_screen.dart';
import 'duel_screen.dart';
import 'history_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, provider, _) {
        final daily = provider.dailyAura;
        return Scaffold(
          body: AuraBackground(
            tint: daily.color,
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(provider: provider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _DailyAuraCard(),
                          const SizedBox(height: 22),
                          _ScanButton(),
                          const SizedBox(height: 26),
                          Text('EXPLORE', style: AppTheme.labelStyle),
                          const SizedBox(height: 12),
                          _MenuGrid(),
                          const SizedBox(height: 26),
                          Text('DAILY CHALLENGES', style: AppTheme.labelStyle),
                          const SizedBox(height: 12),
                          _ChallengeList(provider: provider),
                        ],
                      ),
                    ),
                  ),
                  const BannerAdWidget(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final AuraProvider provider;
  const _TopBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final p = provider.profile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _pill('⭐ ${_fmt(p.auraPoints)}', AppColors.gold),
          const SizedBox(width: 10),
          _pill('🔥 ${p.dailyStreak}', AppColors.accent),
          const Spacer(),
          _pill('LVL ${p.level}', AppColors.secondary),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text,
            style: AppTheme.subtitleStyle.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            )),
      );

  static String _fmt(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return '$v';
  }
}

class _DailyAuraCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AuraProvider>();
    final daily = provider.dailyAura;
    return GlassCard(
      borderColor: daily.color.withValues(alpha: 0.5),
      child: Row(
        children: [
          AuraOrb(colors: daily.gradient, size: 76, emoji: daily.emoji),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AURA OF THE DAY', style: AppTheme.labelStyle),
                const SizedBox(height: 4),
                Text(daily.name,
                    style: AppTheme.titleStyle.copyWith(color: daily.color)),
                const SizedBox(height: 4),
                Text(daily.vibe,
                    style: AppTheme.bodyStyle, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FeedbackService().medium();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ScanScreen()));
      },
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔮', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Text(
              'SCAN MY AURA',
              style: AppTheme.headlineStyle.copyWith(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('⚔️', 'Duel', const DuelScreen()),
      _MenuItem('🗂️', 'Collection', const HistoryScreen()),
      _MenuItem('🏆', 'Ranks', const LeaderboardScreen()),
      _MenuItem('🛍️', 'Shop', const ShopScreen()),
      _MenuItem('🎖️', 'Awards', const AchievementsScreen()),
      _MenuItem('👤', 'Profile', const ProfileScreen()),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: items
          .map((item) => GlassCard(
                padding: const EdgeInsets.all(10),
                onTap: () {
                  FeedbackService().tap();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => item.screen));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 8),
                    Text(item.label, style: AppTheme.bodyStyle),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MenuItem {
  final String emoji;
  final String label;
  final Widget screen;
  _MenuItem(this.emoji, this.label, this.screen);
}

class _ChallengeList extends StatelessWidget {
  final AuraProvider provider;
  const _ChallengeList({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: provider.todaysChallenges.map((c) {
        final progress = provider.challengeProgress(c);
        final complete = provider.isChallengeComplete(c);
        final ratio = (progress / c.target).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            borderColor:
                complete ? AppColors.success.withValues(alpha: 0.6) : null,
            child: Row(
              children: [
                Text(c.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.title,
                          style: AppTheme.bodyStyle
                              .copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: AppColors.cardBorder,
                          valueColor: AlwaysStoppedAnimation(
                            complete ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                complete
                    ? const Icon(Icons.check_circle,
                        color: AppColors.success, size: 26)
                    : Text('+${c.auraReward}',
                        style: AppTheme.bodyStyle
                            .copyWith(color: AppColors.gold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
