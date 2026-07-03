import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/daily_challenge.dart';
import '../providers/game_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/shake_button.dart';
import '../widgets/banner_ad_widget.dart';
import 'mode_select_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  final List<EmberParticle> _embers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateEmbers);
    _bgController.repeat();
    _initEmbers();
  }

  void _initEmbers() {
    for (int i = 0; i < 20; i++) {
      _embers.add(EmberParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 3,
        speed: 0.001 + _random.nextDouble() * 0.002,
        opacity: 0.3 + _random.nextDouble() * 0.4,
      ));
    }
  }

  void _updateEmbers() {
    setState(() {
      for (var ember in _embers) {
        ember.y -= ember.speed;
        ember.x += (sin(ember.y * 10) * 0.002);
        if (ember.y < 0) {
          ember.y = 1.0;
          ember.x = _random.nextDouble();
        }
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A0A0F),
                      Color(0xFF1A0A0A),
                      Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: EmberPainter(embers: _embers),
                size: Size.infinite,
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, gameProvider),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildStatsCard(gameProvider)
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 40),
                            ShakeButton(
                              onPressed: () => _navigateToModeSelect(context),
                              size: 180,
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 600.ms)
                                .scale(begin: const Offset(0.8, 0.8)),
                            const SizedBox(height: 40),
                            _buildDailyChallenge(gameProvider)
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 24),
                            _buildQuickStats(gameProvider)
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 600.ms),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomNav(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          const Spacer(),
          Text(
            'RAGE SHAKE',
            style: AppTheme.headlineStyle.copyWith(
              fontSize: 28,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    Color(0xFFFF6B00),
                    Color(0xFFFF2D00),
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.3)),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: RageColors.primary[RageLevel.heated]!.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 20),
                  Text(
                    'Lv.${provider.userProgress.currentLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(GameProvider provider) {
    return GlassCard(
      glowColor: RageColors.primary[RageLevel.heated],
      child: Column(
        children: [
          Text(
            "TODAY'S RAGE",
            style: AppTheme.subtitleStyle.copyWith(
              letterSpacing: 2,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.userProgress.formattedDailyDestruction,
                style: AppTheme.numberStyle.copyWith(
                  fontSize: 42,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        RageColors.primary[RageLevel.heated]!,
                        RageColors.primary[RageLevel.furious]!,
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.whatshot, color: Color(0xFFFF6B00), size: 32),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'destroyed',
            style: AppTheme.bodyStyle.copyWith(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.userProgress.dailyProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(
                RageColors.lerpPrimary(provider.userProgress.dailyProgress),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(provider.userProgress.dailyProgress * 100).toInt()}% of daily goal',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenge(GameProvider provider) {
    final challenges = provider.todaysChallenges;
    final completedCount = provider.completedDailyChallenges.length;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Challenges',
                style: AppTheme.subtitleStyle.copyWith(
                  color: Colors.amber,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: completedCount == 3 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/3',
                  style: AppTheme.bodyStyle.copyWith(
                    color: completedCount == 3 ? Colors.green : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...challenges.map((challenge) => _buildChallengeItem(provider, challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(GameProvider provider, DailyChallenge challenge) {
    final isCompleted = provider.isChallengeCompleted(challenge);
    final progress = provider.getChallengeProgress(challenge);
    final progressText = provider.getChallengeProgressText(challenge);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? Colors.green.withOpacity(0.3)
                  : challenge.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check : challenge.icon,
              color: isCompleted ? Colors.green : challenge.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.white,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isCompleted ? 1.0 : progress,
                    minHeight: 3,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : challenge.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                progressText,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 11,
                  color: isCompleted ? Colors.green : challenge.color,
                ),
              ),
              Text(
                '+${challenge.xpReward} XP',
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(GameProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.bolt,
            value: provider.userProgress.totalSessions.toString(),
            label: 'Sessions',
            color: Colors.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.auto_awesome,
            value: provider.userProgress.totalObjects.toString(),
            label: 'Objects',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.workspace_premium,
            value: 'Lv.${provider.userProgress.currentLevel}',
            label: 'Level',
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.numberStyle.copyWith(fontSize: 20, color: color),
          ),
          Text(
            label,
            style: AppTheme.bodyStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              borderRadius: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, 'Home', true, () {}),
                  _buildNavItem(Icons.sports_esports, 'Modes', false, () {
                    _navigateToModeSelect(context);
                  }),
                  _buildNavItem(Icons.leaderboard, 'Ranks', false, () {}),
                  _buildNavItem(Icons.settings, 'Settings', false, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? RageColors.primary[RageLevel.heated]
                : AppTheme.textMuted,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? RageColors.primary[RageLevel.heated]
                  : AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToModeSelect(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ModeSelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class EmberParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  EmberParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class EmberPainter extends CustomPainter {
  final List<EmberParticle> embers;

  EmberPainter({required this.embers});

  @override
  void paint(Canvas canvas, Size size) {
    for (var ember in embers) {
      final paint = Paint()
        ..color = const Color(0xFFFF6B00).withOpacity(ember.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(ember.x * size.width, ember.y * size.height),
        ember.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant EmberPainter oldDelegate) => true;
}
