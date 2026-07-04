import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/aura_type.dart';
import '../providers/aura_provider.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_orb.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuraProvider>(
      builder: (context, provider, _) {
        final discovered = provider.profile.discoveredAuras;
        final history = provider.profile.history;
        return Scaffold(
          appBar: AppBar(
            title: Text('COLLECTION', style: AppTheme.titleStyle),
          ),
          extendBodyBehindAppBar: true,
          body: AuraBackground(
            tint: AppColors.primary,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    'AURA TYPES  ${discovered.length}/${AuraTypes.all.length}',
                    style: AppTheme.labelStyle,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: AuraTypes.all.map((type) {
                      final unlocked = discovered.contains(type.id);
                      return _AuraTypeTile(type: type, unlocked: unlocked);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text('RECENT SCANS', style: AppTheme.labelStyle),
                  const SizedBox(height: 12),
                  if (history.isEmpty)
                    GlassCard(
                      child: Text(
                        'No scans yet. Head back and scan your aura!',
                        style: AppTheme.bodyStyle,
                      ),
                    )
                  else
                    ...history.take(30).map((r) {
                      final t = r.type;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(t.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(t.name,
                                        style: AppTheme.bodyStyle.copyWith(
                                            color: AppColors.textPrimary)),
                                    Text(_date(r.timestamp),
                                        style: AppTheme.labelStyle),
                                  ],
                                ),
                              ),
                              Text('${r.score}',
                                  style: AppTheme.titleStyle
                                      .copyWith(color: t.color)),
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

  static String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}  ${two(d.hour)}:${two(d.minute)}';
  }
}

class _AuraTypeTile extends StatelessWidget {
  final AuraType type;
  final bool unlocked;
  const _AuraTypeTile({required this.type, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderColor: unlocked ? type.color.withValues(alpha: 0.5) : null,
      child: Row(
        children: [
          Opacity(
            opacity: unlocked ? 1 : 0.25,
            child: AuraOrb(
              colors: unlocked
                  ? type.gradient
                  : const [AppColors.textMuted, AppColors.cardBorder],
              size: 48,
              emoji: unlocked ? type.emoji : '❔',
              pulsing: false,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  unlocked ? type.name : '???',
                  style: AppTheme.bodyStyle.copyWith(
                    color: unlocked ? AppColors.textPrimary : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  type.rarity.label,
                  style: AppTheme.labelStyle
                      .copyWith(color: type.rarity.color, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
