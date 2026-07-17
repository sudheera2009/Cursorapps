import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'providers/trading_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.backgroundAlt,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const BarrelApp());
}

class BarrelApp extends StatelessWidget {
  const BarrelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradingProvider()..initialize(),
      child: MaterialApp(
        title: 'BARREL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _next();
  }

  Future<void> _next() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboardingComplete') ?? false;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            done ? const HomeScreen() : const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.crude, AppColors.gas],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crude.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Text('🛢️', style: TextStyle(fontSize: 52)),
              ),
              const SizedBox(height: 32),
              Text('BARREL',
                  style: AppTheme.displayStyle.copyWith(letterSpacing: 8)),
              const SizedBox(height: 8),
              Text('OIL & GAS TRADING DESK',
                  style: AppTheme.labelStyle.copyWith(letterSpacing: 3)),
            ],
          ),
        ),
      ),
    );
  }
}
