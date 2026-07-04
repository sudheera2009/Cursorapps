import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../services/feedback_service.dart';
import '../widgets/aura_background.dart';
import '../widgets/aura_orb.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_OnbPage> _pages = const [
    _OnbPage(
      emoji: '🔮',
      colors: [AppColors.primary, AppColors.accent],
      title: 'Scan Your Aura',
      body:
          'Place your finger on the scanner and let AURA METER read your energy. '
          'Get a score from 0 to 9999 and discover your aura type.',
    ),
    _OnbPage(
      emoji: '🌈',
      colors: [AppColors.accent, AppColors.secondary],
      title: 'Collect Rare Auras',
      body:
          'From common Azure Calm to the mythic Prismatic Chaos — hunt down all '
          '10 aura types and complete your collection.',
    ),
    _OnbPage(
      emoji: '⚔️',
      colors: [AppColors.gold, AppColors.accent],
      title: 'Duel Your Friends',
      body:
          'Challenge anyone to an aura duel. Higher aura wins. Farm aura points, '
          'climb the ranks, and flex your shareable aura card.',
    ),
  ];

  void _done() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: AuraBackground(
        tint: _pages[_page].colors.first,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _done,
                  child: Text('SKIP',
                      style: AppTheme.labelStyle
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AuraOrb(colors: p.colors, size: 180, emoji: p.emoji),
                          const SizedBox(height: 48),
                          Text(p.title,
                              textAlign: TextAlign.center,
                              style: AppTheme.headlineStyle),
                          const SizedBox(height: 18),
                          Text(p.body,
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyStyle),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? AppColors.primary
                          : AppColors.textMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      FeedbackService().tap();
                      if (isLast) {
                        _done();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isLast ? 'START SCANNING' : 'NEXT',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnbPage {
  final String emoji;
  final List<Color> colors;
  final String title;
  final String body;
  const _OnbPage({
    required this.emoji,
    required this.colors,
    required this.title,
    required this.body,
  });
}
