import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A compact labelled value used on dashboards and stat grids.
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(label.toUpperCase(), style: AppTheme.labelStyle),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTheme.mono(
            size: 18,
            weight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
