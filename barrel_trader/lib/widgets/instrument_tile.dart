import 'package:flutter/material.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/quote.dart';
import 'change_pill.dart';
import 'sparkline.dart';

/// A single row in the market list: symbol, mini chart, price and change.
class InstrumentTile extends StatelessWidget {
  final Instrument instrument;
  final Quote quote;
  final VoidCallback? onTap;
  final bool held;

  const InstrumentTile({
    super.key,
    required this.instrument,
    required this.quote,
    this.onTap,
    this.held = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forChange(quote.change);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: instrument.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(instrument.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(instrument.symbol, style: AppTheme.titleStyle),
                    if (held) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('HELD',
                            style: AppTheme.labelStyle
                                .copyWith(color: AppColors.accent, fontSize: 8)),
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  width: 92,
                  child: Text(
                    instrument.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 34,
                child: Sparkline(data: quote.history, color: color),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Fmt.price(quote.price, instrument.tickSize),
                  style: AppTheme.mono(size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                ChangePill(percent: quote.changePercent, showArrow: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
