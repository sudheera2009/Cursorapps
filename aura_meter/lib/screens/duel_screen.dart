import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/aura_reading.dart';
import '../providers/aura_provider.dart';
import '../services/feedback_service.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_orb.dart';
import '../widgets/glass_card.dart';

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Rival');
  AuraReading? _player;
  AuraReading? _opponent;
  bool _dueling = false;
  bool _resolved = false;
  bool? _won;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startDuel() async {
    final provider = context.read<AuraProvider>();
    FeedbackService().medium();
    setState(() {
      _dueling = true;
      _resolved = false;
      _player = provider.generateReading();
      _opponent = provider.generateOpponent();
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    // Ties resolve in the player's favor for a satisfying UX.
    final won = _player!.score >= _opponent!.score;
    provider.recordDuel(won);
    FeedbackService().reveal();
    setState(() {
      _resolved = true;
      _won = won;
    });
    if (mounted) await showAchievementUnlocks(context, provider);
  }

  void _reset() {
    setState(() {
      _dueling = false;
      _resolved = false;
      _player = null;
      _opponent = null;
      _won = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuraProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('AURA DUEL', style: AppTheme.titleStyle)),
      extendBodyBehindAppBar: true,
      body: AuraBackground(
        tint: AppColors.accent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _dueling ? _buildArena() : _buildSetup(provider),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup(AuraProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const AuraOrb(
          colors: [AppColors.accent, AppColors.primary],
          size: 140,
          emoji: '⚔️',
        ),
        const SizedBox(height: 30),
        Text('CHALLENGE A RIVAL', style: AppTheme.headlineStyle),
        const SizedBox(height: 10),
        Text(
          'Both auras get scanned. Higher aura wins +100 points. '
          'Your win rate: ${provider.profile.winRate}%',
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle,
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: TextField(
            controller: _nameController,
            style: AppTheme.subtitleStyle.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: const Icon(Icons.person, color: AppColors.textMuted),
              hintText: 'Rival name',
              hintStyle: AppTheme.bodyStyle,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: _startDuel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text('START DUEL',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                )),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stat('WON', '${provider.profile.duelsWon}'),
            _stat('PLAYED', '${provider.profile.duelsPlayed}'),
            _stat('WIN %', '${provider.profile.winRate}'),
          ],
        ),
      ],
    );
  }

  Widget _buildArena() {
    final p = _player!;
    final o = _opponent!;
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: _fighter('YOU', p, reveal: _resolved, winner: _won == true),
        ),
        Text('VS',
            style: AppTheme.headlineStyle.copyWith(color: AppColors.accent)),
        Expanded(
          child: _fighter(_nameController.text.isEmpty ? 'Rival' : _nameController.text,
              o,
              reveal: _resolved, winner: _won == false),
        ),
        const SizedBox(height: 10),
        if (_resolved) ...[
          Text(
            _won! ? 'YOU WIN! +100 ⭐' : 'YOU LOST…',
            style: AppTheme.headlineStyle.copyWith(
              color: _won! ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('EXIT', style: AppTheme.bodyStyle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('REMATCH'),
                ),
              ),
            ],
          ),
        ] else
          Text('SCANNING AURAS…',
              style: AppTheme.subtitleStyle.copyWith(color: AppColors.accent)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _fighter(String name, AuraReading r,
      {required bool reveal, required bool winner}) {
    final t = r.type;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: reveal ? 1 : 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuraOrb(colors: t.gradient, size: 64, emoji: t.emoji),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toUpperCase(),
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  Text(t.name, style: AppTheme.bodyStyle.copyWith(color: t.color)),
                  const SizedBox(height: 4),
                  Text(
                    reveal ? '${r.score}' : '????',
                    style: AppTheme.headlineStyle.copyWith(
                      color: winner ? AppColors.gold : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (reveal && winner) ...[
                const SizedBox(width: 8),
                const Text('👑', style: TextStyle(fontSize: 28)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          const SizedBox(height: 12),
          Text(value,
              style: AppTheme.subtitleStyle
                  .copyWith(color: AppColors.textPrimary)),
          Text(label, style: AppTheme.labelStyle),
        ],
      );
}
