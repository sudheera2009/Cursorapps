import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../providers/trading_provider.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      emoji: '🛢️',
      color: AppColors.crude,
      title: 'Trade oil & gas',
      body:
          'Buy and sell WTI, Brent, Henry Hub natural gas and refined products '
          'in a fast, realistic market simulation.',
    ),
    _OnboardPage(
      emoji: '📈',
      color: AppColors.gas,
      title: 'Go long or short',
      body:
          'Prices tick live every second. Profit when your call is right — '
          'whichever way the market moves.',
    ),
    _OnboardPage(
      emoji: '💵',
      color: AppColors.up,
      title: '\$100,000 to practice',
      body:
          'Start with a virtual balance, track your P&L and sharpen your '
          'strategy. No real money, no risk.',
    ),
  ];

  Future<void> _finish() async {
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
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 14)),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppColors.primary
                        : AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isLast
                        ? 'Start trading with ${Fmt.money0(TradingProvider.startingCash)}'
                        : 'Next',
                    style: AppTheme.titleStyle
                        .copyWith(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final Color color;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 40),
          Text(title, style: AppTheme.headlineStyle, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTheme.subtitleStyle.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
