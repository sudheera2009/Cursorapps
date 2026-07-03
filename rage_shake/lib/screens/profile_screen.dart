import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/game_state.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/banner_ad_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final progress = provider.userProgress;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0A1A),
                  Color(0xFF0A0A0F),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildLevelCard(progress),
                    const SizedBox(height: 24),
                    _buildStatsSection(progress),
                    const SizedBox(height: 24),
                    const InlineBannerAd(),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(progress),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(),
        Text(
          'PROFILE',
          style: AppTheme.titleStyle.copyWith(letterSpacing: 2),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildLevelCard(UserProgress progress) {
    return GlassCard(
      glowColor: Colors.amber,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${progress.currentLevel}',
                    style: AppTheme.numberStyle.copyWith(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'LEVEL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 20),
          Text(
            _getLevelTitle(progress.currentLevel),
            style: AppTheme.titleStyle.copyWith(
              color: Colors.amber,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'XP Progress',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                  Text(
                    '${progress.currentXP} / ${progress.xpForNextLevel}',
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 12,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress.levelProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsSection(UserProgress progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIFETIME STATS',
          style: AppTheme.subtitleStyle.copyWith(
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.attach_money,
                value: progress.formattedTotalDestruction,
                label: 'Total Destroyed',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.broken_image,
                value: progress.totalObjects.toString(),
                label: 'Objects',
                color: Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.play_circle,
                value: progress.totalSessions.toString(),
                label: 'Sessions',
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                value: progress.achievements.length.toString(),
                label: 'Achievements',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.numberStyle.copyWith(
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(UserProgress progress) {
    final unlockedIds = progress.achievements.toSet();
    final unlockedCount = unlockedIds.length;
    final totalCount = Achievements.all.length;
    
    // Sort achievements: unlocked first, then by XP reward
    final sortedAchievements = List<Achievement>.from(Achievements.all)
      ..sort((a, b) {
        final aUnlocked = unlockedIds.contains(a.id);
        final bUnlocked = unlockedIds.contains(b.id);
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;
        return b.xpReward.compareTo(a.xpReward);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ACHIEVEMENTS',
              style: AppTheme.subtitleStyle.copyWith(
                letterSpacing: 2,
                color: AppTheme.textMuted,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unlockedCount/$totalCount',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...sortedAchievements.map((achievement) {
          final isUnlocked = unlockedIds.contains(achievement.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              glowColor: isUnlocked ? achievement.color : null,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isUnlocked ? achievement.color : Colors.grey)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      achievement.icon,
                      color: isUnlocked ? achievement.color : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.name,
                          style: AppTheme.subtitleStyle.copyWith(
                            color: isUnlocked ? Colors.white : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        if (!isUnlocked)
                          Text(
                            '+${achievement.xpReward} XP',
                            style: AppTheme.bodyStyle.copyWith(
                              fontSize: 10,
                              color: achievement.color.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Icon(Icons.check_circle, color: achievement.color),
                  if (!isUnlocked)
                    const Icon(Icons.lock, color: Colors.grey),
                ],
              ),
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  String _getLevelTitle(int level) {
    if (level >= 20) return 'UNIVERSAL OBLITERATOR';
    if (level >= 15) return 'APOCALYPSE AVATAR';
    if (level >= 10) return 'CHAOS CHAMPION';
    if (level >= 7) return 'DESTRUCTION DEMON';
    if (level >= 5) return 'SHAKE SPECIALIST';
    if (level >= 3) return 'MILD MANIAC';
    return 'CALM KAREN';
  }
}
