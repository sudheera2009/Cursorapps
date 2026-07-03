import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

class TutorialHint {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String trigger; // when to show this hint

  const TutorialHint({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.trigger,
  });
}

class TutorialHints {
  static const List<TutorialHint> all = [
    TutorialHint(
      id: 'shake_to_destroy',
      title: 'Shake to Destroy!',
      message: 'Shake your phone harder to deal more damage!',
      icon: Icons.vibration,
      color: Color(0xFFFF9800),
      trigger: 'game_start',
    ),
    TutorialHint(
      id: 'tap_button',
      title: 'Tap for More!',
      message: 'Tap the DESTROY button for manual destruction!',
      icon: Icons.touch_app,
      color: Color(0xFF2196F3),
      trigger: 'first_shake',
    ),
    TutorialHint(
      id: 'build_combo',
      title: 'Build Combos!',
      message: 'Keep destroying to build combos and deal more damage!',
      icon: Icons.bolt,
      color: Color(0xFFFFEB3B),
      trigger: 'combo_5',
    ),
    TutorialHint(
      id: 'rage_meter',
      title: 'Watch Your Rage!',
      message: 'Your rage increases with intensity. Nuclear rage = max destruction!',
      icon: Icons.local_fire_department,
      color: Color(0xFFF44336),
      trigger: 'rage_50',
    ),
    TutorialHint(
      id: 'earn_coins',
      title: 'Rage Coins!',
      message: 'Earn coins by destroying! Use them to unlock themes!',
      icon: Icons.paid,
      color: Color(0xFFFFD700),
      trigger: 'session_end',
    ),
    TutorialHint(
      id: 'daily_challenges',
      title: 'Daily Challenges!',
      message: 'Complete daily challenges for bonus XP!',
      icon: Icons.event_available,
      color: Color(0xFF9C27B0),
      trigger: 'home_first',
    ),
    TutorialHint(
      id: 'try_modes',
      title: 'Try Other Modes!',
      message: 'Each destruction mode has unique objects and effects!',
      icon: Icons.grid_view,
      color: Color(0xFF00BCD4),
      trigger: 'session_3',
    ),
  ];
}

class TutorialHintManager {
  static final TutorialHintManager _instance = TutorialHintManager._internal();
  factory TutorialHintManager() => _instance;
  TutorialHintManager._internal();

  final Set<String> _shownHints = {};
  bool _hintsLoaded = false;

  Future<void> loadShownHints() async {
    if (_hintsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getStringList('shown_tutorial_hints') ?? [];
    _shownHints.addAll(shown);
    _hintsLoaded = true;
  }

  Future<void> markHintShown(String hintId) async {
    _shownHints.add(hintId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('shown_tutorial_hints', _shownHints.toList());
  }

  bool shouldShowHint(String hintId) {
    return !_shownHints.contains(hintId);
  }

  TutorialHint? getHintForTrigger(String trigger) {
    try {
      final hint = TutorialHints.all.firstWhere(
        (h) => h.trigger == trigger && shouldShowHint(h.id),
      );
      return hint;
    } catch (_) {
      return null;
    }
  }

  Future<void> resetHints() async {
    _shownHints.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shown_tutorial_hints');
  }
}

class TutorialHintOverlay extends StatefulWidget {
  final TutorialHint hint;
  final VoidCallback? onDismiss;

  const TutorialHintOverlay({
    super.key,
    required this.hint,
    this.onDismiss,
  });

  @override
  State<TutorialHintOverlay> createState() => _TutorialHintOverlayState();
}

class _TutorialHintOverlayState extends State<TutorialHintOverlay> {
  @override
  void initState() {
    super.initState();
    TutorialHintManager().markHintShown(widget.hint.id);
    
    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.hint.color.withOpacity(0.9),
              widget.hint.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.hint.color.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.hint.icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.hint.title,
                    style: AppTheme.subtitleStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.hint.message,
                    style: AppTheme.bodyStyle.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.5, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .then()
        .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.2)),
    );
  }
}

class TutorialHintWidget extends StatefulWidget {
  final String trigger;
  final Widget child;

  const TutorialHintWidget({
    super.key,
    required this.trigger,
    required this.child,
  });

  @override
  State<TutorialHintWidget> createState() => _TutorialHintWidgetState();
}

class _TutorialHintWidgetState extends State<TutorialHintWidget> {
  TutorialHint? _currentHint;

  @override
  void initState() {
    super.initState();
    _checkForHint();
  }

  Future<void> _checkForHint() async {
    await TutorialHintManager().loadShownHints();
    final hint = TutorialHintManager().getHintForTrigger(widget.trigger);
    if (mounted && hint != null) {
      setState(() => _currentHint = hint);
    }
  }

  void _dismissHint() {
    setState(() => _currentHint = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentHint != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: TutorialHintOverlay(
                hint: _currentHint!,
                onDismiss: _dismissHint,
              ),
            ),
          ),
      ],
    );
  }
}
