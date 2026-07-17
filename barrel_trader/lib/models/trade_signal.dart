import 'package:flutter/material.dart';

import '../core/theme.dart';

enum SignalAction { buy, sell, wait }

extension SignalActionX on SignalAction {
  String get label {
    switch (this) {
      case SignalAction.buy:
        return 'BUY';
      case SignalAction.sell:
        return 'SELL';
      case SignalAction.wait:
        return 'WAIT';
    }
  }

  Color get color {
    switch (this) {
      case SignalAction.buy:
        return AppColors.up;
      case SignalAction.sell:
        return AppColors.down;
      case SignalAction.wait:
        return AppColors.neutral;
    }
  }

  IconData get icon {
    switch (this) {
      case SignalAction.buy:
        return Icons.trending_up;
      case SignalAction.sell:
        return Icons.trending_down;
      case SignalAction.wait:
        return Icons.pause_circle_outline;
    }
  }
}

/// A single human-readable driver behind a signal.
class SignalReason {
  final String text;
  final bool bullish;
  final double weight; // absolute contribution magnitude

  const SignalReason(this.text, this.bullish, this.weight);
}

/// The output of the Signal Generation Engine: an actionable call with a
/// confidence score and the reasons behind it.
class TradeSignal {
  final String instrumentId;
  final SignalAction action;

  /// Model's estimated probability the next move is up (0..1).
  final double probabilityUp;

  /// Confidence in the call (0..1), i.e. distance of [probabilityUp] from 0.5.
  final double confidence;

  final List<SignalReason> reasons;
  final DateTime timestamp;

  const TradeSignal({
    required this.instrumentId,
    required this.action,
    required this.probabilityUp,
    required this.confidence,
    required this.reasons,
    required this.timestamp,
  });

  int get confidencePercent => (confidence * 100).round();

  /// A short strength label derived from confidence.
  String get strength {
    if (confidence >= 0.6) return 'Strong';
    if (confidence >= 0.3) return 'Moderate';
    return 'Weak';
  }
}
