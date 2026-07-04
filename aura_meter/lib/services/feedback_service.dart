import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

/// Handles haptics and lightweight UI feedback plus the related user settings.
///
/// The app deliberately avoids bundling audio assets, so "sound" is delivered
/// through the platform's system sounds and the vibration motor.
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  bool _hapticsEnabled = true;
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  bool? _hasVibrator;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('animationsEnabled', _animationsEnabled);
  }

  void setHaptics(bool v) {
    _hapticsEnabled = v;
    _save();
  }

  void setSound(bool v) {
    _soundEnabled = v;
    _save();
  }

  void setAnimations(bool v) {
    _animationsEnabled = v;
    _save();
  }

  void tap() {
    if (_soundEnabled) SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) HapticFeedback.selectionClick();
  }

  void light() {
    if (_hapticsEnabled) HapticFeedback.lightImpact();
  }

  void medium() {
    if (_hapticsEnabled) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (_hapticsEnabled) HapticFeedback.heavyImpact();
  }

  /// A rising "scanning" buzz pattern used during the scan animation.
  void scanPulse() {
    if (!_hapticsEnabled) return;
    if (_hasVibrator == true) {
      try {
        Vibration.vibrate(
          pattern: [0, 40, 120, 60, 120, 90, 100, 140],
          intensities: [0, 80, 0, 130, 0, 190, 0, 255],
        );
        return;
      } catch (_) {}
    }
    HapticFeedback.mediumImpact();
  }

  /// A celebratory burst used when a rare aura is revealed.
  void reveal() {
    if (!_hapticsEnabled) return;
    if (_hasVibrator == true) {
      try {
        Vibration.vibrate(duration: 220, amplitude: 255);
        return;
      } catch (_) {}
    }
    HapticFeedback.heavyImpact();
  }
}
