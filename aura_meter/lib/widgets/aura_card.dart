import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/aura_frame.dart';
import '../models/aura_reading.dart';
import '../models/aura_type.dart';
import 'aura_orb.dart';

/// The shareable card rendered from a scan result. Wrapped in a
/// RepaintBoundary by the caller for image capture.
class AuraCard extends StatelessWidget {
  final AuraReading reading;
  final AuraFrame frame;

  const AuraCard({super.key, required this.reading, required this.frame});

  @override
  Widget build(BuildContext context) {
    final type = reading.type;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: frame.colors,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF120F24), Color(0xFF07060F)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AURA METER', style: AppTheme.labelStyle),
            const SizedBox(height: 20),
            AuraOrb(
              colors: type.gradient,
              size: 130,
              emoji: type.emoji,
              pulsing: false,
            ),
            const SizedBox(height: 20),
            Text(
              type.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTheme.titleStyle.copyWith(color: type.color),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: type.rarity.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: type.rarity.color, width: 1),
              ),
              child: Text(
                type.rarity.label,
                style: AppTheme.labelStyle.copyWith(color: type.rarity.color),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${reading.score}',
              style: AppTheme.numberStyle.copyWith(
                fontSize: 68,
                color: Colors.white,
                shadows: [
                  Shadow(color: type.glow, blurRadius: 24),
                ],
              ),
            ),
            Text('AURA SCORE', style: AppTheme.labelStyle),
            const SizedBox(height: 14),
            Text(
              '“${type.vibe}”',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _trait('CHARISMA', reading.charisma),
                _trait('CHAOS', reading.chaos),
                _trait('LUCK', reading.luck),
                _trait('MYSTERY', reading.mystery),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'scan yours 🔮 #AuraMeter',
              style: AppTheme.labelStyle.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trait(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTheme.subtitleStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.labelStyle.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
