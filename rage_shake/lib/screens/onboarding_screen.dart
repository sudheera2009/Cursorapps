import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'WELCOME TO\nRAGE SHAKE',
      description: 'The ultimate stress relief app.\nDestroy everything. Feel better.',
      icon: Icons.whatshot,
      color: const Color(0xFFFF6B00),
      gradient: const [Color(0xFF2A0A0A), Color(0xFF0A0A0F)],
    ),
    OnboardingPage(
      title: 'SHAKE TO\nDESTROY',
      description: 'Shake your phone to unleash destruction.\nThe harder you shake, the more damage!',
      icon: Icons.vibration,
      color: const Color(0xFFFF2D00),
      gradient: const [Color(0xFF1A0A0A), Color(0xFF0A0A0F)],
    ),
    OnboardingPage(
      title: 'BUILD YOUR\nRAGE',
      description: 'Watch your rage meter fill up.\nReach NUCLEAR for maximum destruction!',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFFD700),
      gradient: const [Color(0xFF2A1A0A), Color(0xFF0A0A0F)],
    ),
    OnboardingPage(
      title: 'MULTIPLE\nMODES',
      description: 'Office, Kitchen, Cars, Cities, Space...\nUnlock new destruction modes as you level up!',
      icon: Icons.grid_view,
      color: const Color(0xFF9C27B0),
      gradient: const [Color(0xFF1A0A2A), Color(0xFF0A0A0F)],
    ),
    OnboardingPage(
      title: 'COMPETE &\nSHARE',
      description: 'Track your stats, earn achievements,\nand share your destruction scores!',
      icon: Icons.emoji_events,
      color: const Color(0xFF00BCD4),
      gradient: const [Color(0xFF0A1A2A), Color(0xFF0A0A0F)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'BACK',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'SKIP',
                      style: AppTheme.bodyStyle.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _pages[_currentPage].color,
                          _pages[_currentPage].color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentPage].color.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'START' : 'NEXT',
                      style: AppTheme.titleStyle.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
                    .animate(key: ValueKey(_currentPage))
                    .scale(begin: const Offset(0.9, 0.9), duration: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.color.withOpacity(0.2),
                  border: Border.all(
                    color: page.color.withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  page.icon,
                  size: 80,
                  color: page.color,
                ),
              )
                  .animate(key: ValueKey(page.title))
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 60),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: AppTheme.headlineStyle.copyWith(
                  fontSize: 36,
                  height: 1.2,
                ),
              )
                  .animate(key: ValueKey('${page.title}title'))
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle.copyWith(
                  fontSize: 16,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              )
                  .animate(key: ValueKey('${page.title}desc'))
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : AppTheme.textMuted.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
