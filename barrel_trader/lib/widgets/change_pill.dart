import 'package:flutter/material.dart';

import '../core/formatting.dart';
import '../core/theme.dart';

/// A small colored pill showing a signed percentage change (green/red).
class ChangePill extends StatelessWidget {
  final double percent;
  final bool showArrow;
  final double fontSize;

  const ChangePill({
    super.key,
    required this.percent,
    this.showArrow = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forChange(percent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showArrow)
            Icon(
              percent > 0
                  ? Icons.arrow_drop_up
                  : (percent < 0 ? Icons.arrow_drop_down : Icons.remove),
              color: color,
              size: fontSize + 6,
            ),
          Text(
            Fmt.signedPercent(percent),
            style: AppTheme.mono(
              size: fontSize,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
