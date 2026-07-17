import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/trade_signal.dart';

/// A pill showing a signal action (BUY / SELL / WAIT) with an icon.
class SignalBadge extends StatelessWidget {
  final SignalAction action;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const SignalBadge({
    super.key,
    required this.action,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    final color = action.color;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: color, size: fontSize + 3),
          const SizedBox(width: 5),
          Text(
            action.label,
            style: AppTheme.labelStyle.copyWith(
              color: color,
              fontSize: fontSize,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// A thin horizontal confidence meter.
class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0..1
  final Color color;

  const ConfidenceBar({super.key, required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: confidence.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: AppColors.cardAlt,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
