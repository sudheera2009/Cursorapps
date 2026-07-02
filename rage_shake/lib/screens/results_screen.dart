import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme.dart';
import '../models/game_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/shake_button.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class ResultsScreen extends StatefulWidget {
  final GameSession session;

  const ResultsScreen({super.key, required this.session});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.session.totalDamage,
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
      _scoreController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showStats = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.session.mode.color.withOpacity(0.3),
                  const Color(0xFF0A0A0F),
                  const Color(0xFF0A0A0F),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildScoreCard(),
                  const SizedBox(height: 24),
                  if (_showStats) ...[
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildRageStats(),
                    const SizedBox(height: 40),
                  ],
                  _buildActions(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: [
                widget.session.mode.color,
                Colors.amber,
                Colors.orange,
                Colors.red,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.emoji_events,
          color: Colors.amber,
          size: 60,
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),
        const SizedBox(height: 16),
        Text(
          'DESTRUCTION',
          style: AppTheme.headlineStyle.copyWith(
            fontSize: 42,
            letterSpacing: 4,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
        Text(
          'COMPLETE',
          style: AppTheme.headlineStyle.copyWith(
            fontSize: 42,
            letterSpacing: 4,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  widget.session.mode.color,
                  Colors.amber,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildScoreCard() {
    return GlassCard(
      glowColor: widget.session.mode.color,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Text(
                _formatScore(_scoreAnimation.value),
                style: AppTheme.numberStyle.copyWith(
                  fontSize: 56,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        Colors.white,
                        widget.session.mode.color,
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 80)),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'TOTAL DESTRUCTION',
            style: AppTheme.subtitleStyle.copyWith(
              letterSpacing: 2,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.session.mode.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.session.mode.color.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.session.mode.icon,
                  color: widget.session.mode.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.session.mode.name,
                  style: AppTheme.bodyStyle.copyWith(
                    color: widget.session.mode.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.broken_image,
            value: widget.session.objectsDestroyed.toString(),
            label: 'Objects',
            color: Colors.cyan,
            delay: 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bolt,
            value: 'x${widget.session.maxCombo}',
            label: 'Max Combo',
            color: Colors.amber,
            delay: 100,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            value: widget.session.formattedDuration,
            label: 'Duration',
            color: Colors.purple,
            delay: 200,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int delay,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.numberStyle.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildRageStats() {
    final rageLevel = RageColors.getLevel(widget.session.rageLevel);
    final rageName = _getRageLevelName(rageLevel);
    final rageColor = RageColors.getPrimary(rageLevel);

    return GlassCard(
      glowColor: rageColor,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rageColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: rageColor.withOpacity(0.5)),
            ),
            child: Icon(
              rageLevel == RageLevel.nuclear
                  ? Icons.whatshot
                  : Icons.local_fire_department,
              color: rageColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PEAK RAGE',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rageName,
                  style: AppTheme.titleStyle.copyWith(
                    color: rageColor,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(widget.session.rageLevel * 100).toInt()}%',
            style: AppTheme.numberStyle.copyWith(
              color: rageColor,
              fontSize: 28,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MiniShakeButton(
                onPressed: () => _shareResult(),
                text: 'SHARE',
                icon: Icons.share,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MiniShakeButton(
                onPressed: () => _playAgain(context),
                text: 'AGAIN',
                icon: Icons.replay,
                color: widget.session.mode.color,
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _goHome(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Back to Home',
                  style: AppTheme.bodyStyle.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms),
      ],
    );
  }

  void _shareResult() {
    final text = '''
🔥 RAGE SHAKE RESULTS 🔥

💥 Destroyed: ${widget.session.formattedDamage}
🎯 Objects: ${widget.session.objectsDestroyed}
⚡ Max Combo: x${widget.session.maxCombo}
⏱️ Time: ${widget.session.formattedDuration}
🎮 Mode: ${widget.session.mode.name}

Can you beat my score? Download RAGE SHAKE now!
    ''';
    Share.share(text);
  }

  void _playAgain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(mode: widget.session.mode),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  String _formatScore(int score) {
    if (score >= 1000000000) {
      return '\$${(score / 1000000000).toStringAsFixed(1)}B';
    } else if (score >= 1000000) {
      return '\$${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '\$${(score / 1000).toStringAsFixed(1)}K';
    }
    return '\$$score';
  }

  String _getRageLevelName(RageLevel level) {
    switch (level) {
      case RageLevel.calm:
        return 'CALM';
      case RageLevel.annoyed:
        return 'ANNOYED';
      case RageLevel.heated:
        return 'HEATED';
      case RageLevel.furious:
        return 'FURIOUS';
      case RageLevel.nuclear:
        return '☢ NUCLEAR ☢';
    }
  }
}
