import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/theme.dart';
import '../models/destruction_mode.dart';
import '../providers/game_provider.dart';
import '../widgets/rage_meter.dart';
import '../widgets/particle_system.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  final DestructionMode mode;

  const GameScreen({super.key, required this.mode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late AnimationController _updateController;
  final Random _random = Random();
  bool _isCountingDown = true;
  int _countdown = 3;
  Timer? _countdownTimer;
  final List<DestructionTarget> _targets = [];

  @override
  void initState() {
    super.initState();
    _updateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _isCountingDown = false;
          timer.cancel();
          _startGame();
        }
      });
    });
  }

  void _startGame() {
    final provider = context.read<GameProvider>();
    provider.startGame(widget.mode);
    _initTargets();
    _startAccelerometer();
    _updateController.repeat();
  }

  void _initTargets() {
    _targets.clear();
    for (int i = 0; i < 8; i++) {
      _spawnTarget();
    }
  }

  void _spawnTarget() {
    final obj = widget.mode.objects[_random.nextInt(widget.mode.objects.length)];
    _targets.add(DestructionTarget(
      object: obj,
      position: Offset(
        50 + _random.nextDouble() * 250,
        100 + _random.nextDouble() * 400,
      ),
      scale: 0.8 + _random.nextDouble() * 0.4,
    ));
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!_isCountingDown) {
        final provider = context.read<GameProvider>();
        provider.processShake(event.x, event.y, event.z);
      }
    });
  }

  void _update() {
    if (!_isCountingDown) {
      final provider = context.read<GameProvider>();
      provider.updateParticles();

      for (var target in _targets) {
        if (provider.isShaking) {
          target.shake = provider.shakeIntensity;
        } else {
          target.shake = target.shake * 0.9;
        }
      }
    }
  }

  void _onTargetTap(DestructionTarget target) {
    final provider = context.read<GameProvider>();
    provider.manualDestroy(target.position);

    setState(() {
      _targets.remove(target);
      _spawnTarget();
    });
  }

  void _endGame() {
    final provider = context.read<GameProvider>();
    provider.endGame();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ResultsScreen(session: provider.currentSession!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _updateController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final rageLevel = provider.currentSession?.rageLevel ?? 0.0;
        final bgColor = RageColors.lerpBackground(rageLevel);

        return Scaffold(
          body: ScreenShake(
            intensity: provider.isShaking ? provider.shakeIntensity : 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    bgColor,
                    bgColor.withOpacity(0.8),
                    const Color(0xFF0A0A0F),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    if (!_isCountingDown) ...[
                      ..._targets.map((target) => _buildTarget(target, provider)),
                      ParticleOverlay(
                        particles: provider.particles,
                        damages: provider.floatingDamages,
                        rageLevel: rageLevel,
                      ),
                      _buildHUD(provider),
                      _buildRageMeterVertical(provider),
                      _buildEndButton(),
                    ],
                    if (_isCountingDown) _buildCountdown(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdown() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.mode.name,
            style: AppTheme.titleStyle.copyWith(
              color: widget.mode.color,
              fontSize: 28,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.5, end: 0),
          const SizedBox(height: 40),
          Text(
            _countdown > 0 ? _countdown.toString() : 'GO!',
            style: AppTheme.headlineStyle.copyWith(
              fontSize: 120,
              color: _countdown > 0
                  ? RageColors.lerpPrimary(_countdown / 3)
                  : Colors.white,
            ),
          )
              .animate(
                onPlay: (c) => c.forward(),
                key: ValueKey(_countdown),
              )
              .scale(
                begin: const Offset(1.5, 1.5),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 200.ms),
          const SizedBox(height: 40),
          Text(
            'SHAKE YOUR PHONE!',
            style: AppTheme.subtitleStyle.copyWith(
              letterSpacing: 3,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn()
              .then()
              .shimmer(duration: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildTarget(DestructionTarget target, GameProvider provider) {
    final shakeOffset = Offset(
      (_random.nextDouble() - 0.5) * target.shake * 20,
      (_random.nextDouble() - 0.5) * target.shake * 20,
    );

    return Positioned(
      left: target.position.dx + shakeOffset.dx - 30,
      top: target.position.dy + shakeOffset.dy - 30,
      child: GestureDetector(
        onTap: () => _onTargetTap(target),
        child: AnimatedScale(
          scale: target.scale + target.shake * 0.1,
          duration: const Duration(milliseconds: 50),
          child: Container(
            width: 60 * target.object.size,
            height: 60 * target.object.size,
            decoration: BoxDecoration(
              color: widget.mode.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.mode.color.withOpacity(0.5 + target.shake * 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.mode.color.withOpacity(target.shake * 0.5),
                  blurRadius: 10 + target.shake * 20,
                  spreadRadius: target.shake * 5,
                ),
              ],
            ),
            child: Icon(
              target.object.icon,
              color: widget.mode.color,
              size: 30 * target.object.size,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(GameProvider provider) {
    final session = provider.currentSession;
    if (session == null) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 60,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.formattedDamage,
                  style: AppTheme.numberStyle.copyWith(
                    fontSize: 32,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          RageColors.lerpPrimary(session.rageLevel),
                          Colors.white,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                  ),
                ),
                if (session.currentCombo > 1)
                  Text(
                    'x${session.currentCombo} COMBO',
                    style: AppTheme.subtitleStyle.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.1, 1.1),
                        duration: 200.ms,
                      ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white70, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      session.formattedDuration,
                      style: AppTheme.subtitleStyle.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RageLevelIndicator(
                  level: RageColors.getLevel(session.rageLevel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRageMeterVertical(GameProvider provider) {
    final session = provider.currentSession;
    if (session == null) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      right: 16,
      bottom: 100,
      child: SizedBox(
        width: 40,
        child: Column(
          children: [
            const Icon(Icons.whatshot, color: Colors.white54, size: 20),
            const SizedBox(height: 8),
            Expanded(
              child: RotatedBox(
                quarterTurns: 3,
                child: RageMeter(
                  rageLevel: session.rageLevel,
                  height: 30,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(session.rageLevel * 100).toInt()}%',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 12,
                color: RageColors.lerpPrimary(session.rageLevel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndButton() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: _endGame,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stop, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'END SESSION',
                style: AppTheme.titleStyle.copyWith(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DestructionTarget {
  final DestructibleObject object;
  Offset position;
  double scale;
  double shake;

  DestructionTarget({
    required this.object,
    required this.position,
    this.scale = 1.0,
    this.shake = 0.0,
  });
}
