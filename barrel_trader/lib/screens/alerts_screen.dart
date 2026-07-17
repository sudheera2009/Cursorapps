import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/trade_signal.dart';
import '../providers/trading_provider.dart';
import '../widgets/signal_badge.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();
    final alerts = p.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Alerts'),
        actions: [
          if (alerts.isNotEmpty)
            TextButton(
              onPressed: p.clearAlerts,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: alerts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_none,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    Text('No alerts yet',
                        style: AppTheme.subtitleStyle
                            .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(
                      'Alerts fire when a signal crosses your confidence '
                      'threshold. Tune it in Account → Alerts.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyStyle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: alerts.length,
              itemBuilder: (context, i) {
                final a = alerts[i];
                final inst = Instruments.byId(a.instrumentId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: a.action.color.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(inst.emoji),
                          const SizedBox(width: 8),
                          SignalBadge(action: a.action, fontSize: 11),
                          const Spacer(),
                          Text('${a.confidencePercent}%',
                              style: AppTheme.mono(
                                  size: 13, color: a.action.color)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${inst.symbol} · ${inst.name}',
                        style: AppTheme.subtitleStyle
                            .copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'at ${Fmt.price(a.price, inst.tickSize)} · ${Fmt.timeAgo(a.timestamp)}',
                        style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
