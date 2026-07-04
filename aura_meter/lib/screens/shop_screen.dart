import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/aura_frame.dart';
import '../providers/aura_provider.dart';
import '../services/ad_service.dart';
import '../services/feedback_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/glass_card.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        return Scaffold(
          appBar: AppBar(
            title: Text('AURA SHOP', style: AppTheme.titleStyle),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text('⭐ ${profile.auraPoints}',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.gold)),
                ),
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: AuraBackground(
            tint: AppColors.gold,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  GlassCard(
                    borderColor: AppColors.gold.withValues(alpha: 0.5),
                    onTap: () {
                      FeedbackService().tap();
                      AdService().showRewardedAd(
                        onRewarded: (_) {
                          provider.addAuraPoints(250);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('+250 aura earned! ⭐')),
                          );
                        },
                      );
                    },
                    child: Row(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 34)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FREE AURA',
                                  style: AppTheme.subtitleStyle.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold)),
                              Text('Watch an ad for +250 aura points',
                                  style: AppTheme.bodyStyle),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_circle_fill,
                            color: AppColors.gold, size: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('CARD FRAMES', style: AppTheme.labelStyle),
                  const SizedBox(height: 12),
                  ...AuraFrames.all.map((frame) {
                    final owned = profile.unlockedFrames.contains(frame.id);
                    final selected = profile.currentFrame == frame.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FrameTile(
                        frame: frame,
                        owned: owned,
                        selected: selected,
                        onTap: () {
                          FeedbackService().tap();
                          if (selected) return;
                          if (owned) {
                            provider.selectFrame(frame.id);
                          } else {
                            final ok = provider.purchaseFrame(frame);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok
                                    ? '${frame.name} unlocked & equipped!'
                                    : 'Not enough aura points'),
                              ),
                            );
                          }
                        },
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

class _FrameTile extends StatelessWidget {
  final AuraFrame frame;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  const _FrameTile({
    required this.frame,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor:
          selected ? AppColors.primary.withValues(alpha: 0.8) : null,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: frame.colors),
            ),
            child: Center(
                child:
                    Text(frame.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(frame.name,
                    style: AppTheme.subtitleStyle.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold)),
                Text(
                  frame.cost == 0 ? 'Free' : '⭐ ${frame.cost}',
                  style: AppTheme.bodyStyle.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
          _statusChip(),
        ],
      ),
    );
  }

  Widget _statusChip() {
    String label;
    Color color;
    if (selected) {
      label = 'EQUIPPED';
      color = AppColors.primary;
    } else if (owned) {
      label = 'EQUIP';
      color = AppColors.secondary;
    } else {
      label = 'BUY';
      color = AppColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(label,
          style: AppTheme.labelStyle.copyWith(color: color, fontSize: 11)),
    );
  }
}
