import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FeedbackService _feedback = FeedbackService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SETTINGS', style: AppTheme.titleStyle)),
      extendBodyBehindAppBar: true,
      body: AuraBackground(
        tint: AppColors.primary,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text('FEEDBACK', style: AppTheme.labelStyle),
              const SizedBox(height: 12),
              _toggle(
                'Haptics',
                'Vibrations during scans & reveals',
                _feedback.hapticsEnabled,
                (v) => setState(() => _feedback.setHaptics(v)),
              ),
              _toggle(
                'Sound',
                'Tap & click sounds',
                _feedback.soundEnabled,
                (v) => setState(() => _feedback.setSound(v)),
              ),
              _toggle(
                'Animations',
                'Background & orb effects',
                _feedback.animationsEnabled,
                (v) => setState(() => _feedback.setAnimations(v)),
              ),
              const SizedBox(height: 24),
              Text('DATA', style: AppTheme.labelStyle),
              const SizedBox(height: 12),
              GlassCard(
                onTap: () => _confirmReset(context),
                borderColor: AppColors.danger.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever,
                        color: AppColors.danger),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reset Progress',
                              style: AppTheme.subtitleStyle.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold)),
                          Text('Erase all auras, points and stats',
                              style: AppTheme.bodyStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text('AURA METER v1.0.0',
                    style: AppTheme.labelStyle),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('For entertainment only • not a real reading 🔮',
                    style: AppTheme.bodyStyle
                        .copyWith(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.subtitleStyle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTheme.bodyStyle),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Reset progress?', style: AppTheme.titleStyle),
        content: Text(
          'This permanently erases your auras, points, streak and stats.',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: AppTheme.bodyStyle),
          ),
          TextButton(
            onPressed: () {
              context.read<AuraProvider>().resetAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset')),
              );
            },
            child: Text('RESET',
                style: AppTheme.bodyStyle.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
