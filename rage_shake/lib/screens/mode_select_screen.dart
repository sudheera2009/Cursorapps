import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/destruction_mode.dart';
import '../providers/game_provider.dart';
import '../widgets/mode_card.dart';
import 'game_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  DestructionMode? _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = DestructionModes.office;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0F),
                  Color(0xFF0F0A1A),
                  Color(0xFF0A0A0F),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECT YOUR DESTRUCTION',
                            style: AppTheme.subtitleStyle.copyWith(
                              letterSpacing: 2,
                              color: AppTheme.textMuted,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.1, end: 0),
                          const SizedBox(height: 16),
                          _buildModeGrid(gameProvider),
                          const SizedBox(height: 24),
                          if (_selectedMode != null)
                            ModeDetailPanel(
                              mode: _selectedMode!,
                              onStart: () => _startGame(context, _selectedMode!),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.1, end: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
            'SELECT MODE',
            style: AppTheme.titleStyle.copyWith(
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildModeGrid(GameProvider provider) {
    final modes = DestructionModes.all;
    final userLevel = provider.userProgress.currentLevel;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];
        return ModeCard(
          mode: mode,
          userLevel: userLevel,
          highScore: provider.userProgress.modeHighScores[mode.id],
          isSelected: _selectedMode?.id == mode.id,
          onTap: () {
            if (mode.isUnlocked(userLevel)) {
              setState(() {
                _selectedMode = mode;
              });
            }
          },
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: 400.ms,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              delay: Duration(milliseconds: 100 * index),
            );
      },
    );
  }

  void _startGame(BuildContext context, DestructionMode mode) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(mode: mode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
