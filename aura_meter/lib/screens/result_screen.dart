import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/aura_frame.dart';
import '../models/aura_reading.dart';
import '../models/aura_type.dart';
import '../providers/aura_provider.dart';
import '../services/ad_service.dart';
import '../services/feedback_service.dart';
import '../services/share_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_card.dart';
import '../widgets/banner_ad_widget.dart';
import 'scan_screen.dart';

class ResultScreen extends StatefulWidget {
  final AuraReading reading;
  const ResultScreen({super.key, required this.reading});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _cardKey = GlobalKey();
  late final ConfettiController _confetti;
  bool _bonusClaimed = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    final rarity = widget.reading.type.rarity;
    if (rarity == AuraRarity.epic ||
        rarity == AuraRarity.legendary ||
        rarity == AuraRarity.mythic) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    FeedbackService().tap();
    final bytes = await ShareService().captureWidget(_cardKey);
    if (bytes != null) {
      await ShareService().shareCard(
        bytes,
        text:
            'I scored ${widget.reading.score} aura (${widget.reading.type.name}) on AURA METER 🔮 Can you beat me? #AuraMeter',
      );
    }
  }

  void _doubleAura() {
    if (_bonusClaimed) return;
    FeedbackService().tap();
    final provider = context.read<AuraProvider>();
    final bonus = 20 + (widget.reading.score ~/ 100);
    AdService().showRewardedAd(
      onRewarded: (_) {
        provider.addAuraPoints(bonus);
        setState(() => _bonusClaimed = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('+$bonus bonus aura claimed! ⭐')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuraProvider>();
    final frame = AuraFrames.byId(provider.profile.currentFrame);
    final type = widget.reading.type;
    return Scaffold(
      body: AuraBackground(
        tint: type.color,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Text(widget.reading.tier,
                              style: AppTheme.labelStyle
                                  .copyWith(color: type.rarity.color)),
                          const SizedBox(height: 12),
                          RepaintBoundary(
                            key: _cardKey,
                            child: AuraCard(
                                reading: widget.reading, frame: frame),
                          ),
                          const SizedBox(height: 20),
                          Text(type.description,
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyStyle),
                          const SizedBox(height: 20),
                          _actions(),
                        ],
                      ),
                    ),
                  ),
                  const BannerAdWidget(),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 24,
                  gravity: 0.25,
                  colors: [type.color, type.glow, AppColors.gold, Colors.white],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _btn(
                icon: Icons.share,
                label: 'SHARE',
                color: AppColors.secondary,
                onTap: _share,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _btn(
                icon: _bonusClaimed ? Icons.check : Icons.bolt,
                label: _bonusClaimed ? 'CLAIMED' : '2X AURA',
                color: AppColors.gold,
                onTap: _bonusClaimed ? null : _doubleAura,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              FeedbackService().medium();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Text('🔮', style: TextStyle(fontSize: 22)),
            label: Text('SCAN AGAIN',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                )),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
          child: Text('BACK HOME',
              style: AppTheme.labelStyle
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: color.withValues(alpha: onTap == null ? 0.08 : 0.18),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTheme.bodyStyle.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
