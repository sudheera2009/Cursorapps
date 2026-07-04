import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/aura_provider.dart';
import '../widgets/aura_background.dart';
import '../widgets/glass_card.dart';

/// A simulated global leaderboard. The player is ranked by their best score
/// among a set of generated "rivals" that stays stable within a session.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final List<_Entry> _rivals;

  static const _names = [
    'auraFarmer99', 'sigma_wolf', 'moonchild', 'itzGlow', 'chaos.exe',
    'velvetVibes', 'ghostmode', 'starlord', 'zenkai', 'nova_rae',
    'drippy', 'lunaTic', 'phantom', 'goldenboy', 'mystic.k',
    'rizzler', 'cosmic_kai', 'shadowfax', 'pixelqueen', 'hyperbeam',
  ];

  @override
  void initState() {
    super.initState();
    final rnd = Random(DateTime.now().day * 31 + 7);
    _rivals = List.generate(_names.length, (i) {
      return _Entry(
        name: _names[i],
        score: 2000 + rnd.nextInt(7999),
        isPlayer: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuraProvider>();
    final playerScore = provider.profile.bestScore;
    final entries = [
      ..._rivals,
      _Entry(name: 'YOU', score: playerScore, isPlayer: true),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final rank = entries.indexWhere((e) => e.isPlayer) + 1;

    return Scaffold(
      appBar: AppBar(title: Text('RANKS', style: AppTheme.titleStyle)),
      extendBodyBehindAppBar: true,
      body: AuraBackground(
        tint: AppColors.gold,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlassCard(
                  borderColor: AppColors.gold.withValues(alpha: 0.6),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 40)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('YOUR GLOBAL RANK',
                                style: AppTheme.labelStyle),
                            const SizedBox(height: 4),
                            Text('#$rank',
                                style: AppTheme.headlineStyle
                                    .copyWith(color: AppColors.gold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('BEST', style: AppTheme.labelStyle),
                          Text('$playerScore',
                              style: AppTheme.titleStyle
                                  .copyWith(color: AppColors.textPrimary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        borderColor: e.isPlayer
                            ? AppColors.primary.withValues(alpha: 0.7)
                            : null,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                _medal(i + 1),
                                style: AppTheme.subtitleStyle.copyWith(
                                  color: e.isPlayer
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.name,
                                style: AppTheme.bodyStyle.copyWith(
                                  color: e.isPlayer
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: e.isPlayer
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text('${e.score}',
                                style: AppTheme.subtitleStyle.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _medal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}

class _Entry {
  final String name;
  final int score;
  final bool isPlayer;
  _Entry({required this.name, required this.score, required this.isPlayer});
}
