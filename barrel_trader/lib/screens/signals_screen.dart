import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/trade_signal.dart';
import '../providers/trading_provider.dart';
import '../widgets/panel_card.dart';
import '../widgets/signal_badge.dart';
import 'alerts_screen.dart';
import 'instrument_screen.dart';

class SignalsScreen extends StatelessWidget {
  const SignalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();
    final signals = p.signals;
    final actionable =
        signals.where((s) => s.action != SignalAction.wait).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signals', style: AppTheme.headlineStyle),
                  Text('AI signals from technicals + fundamentals',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                ],
              ),
              const Spacer(),
              _alertsButton(context, p.alerts.length),
            ],
          ),
          const SizedBox(height: 16),
          PanelCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.auto_graph, color: AppColors.gas, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    actionable == 0
                        ? 'No actionable calls right now — mostly WAIT.'
                        : '$actionable actionable ${actionable == 1 ? 'signal' : 'signals'} across the desk.',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...signals.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _signalCard(context, p, s),
              )),
          const SizedBox(height: 8),
          Text(
            'Signals are model estimates on simulated data — not financial '
            'advice.',
            style: AppTheme.bodyStyle
                .copyWith(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _alertsButton(BuildContext context, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AlertsScreen()),
          ),
          icon: const Icon(Icons.notifications_outlined),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.card,
            side: const BorderSide(color: AppColors.cardBorder),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                color: AppColors.crude,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: AppTheme.labelStyle
                    .copyWith(color: Colors.black, fontSize: 9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _signalCard(BuildContext context, TradingProvider p, TradeSignal s) {
    final inst = Instruments.byId(s.instrumentId);
    return PanelCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InstrumentScreen(instrumentId: s.instrumentId),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(inst.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inst.symbol, style: AppTheme.titleStyle),
                  Text(inst.name,
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                ],
              ),
              const Spacer(),
              SignalBadge(action: s.action),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('${s.strength} · ${s.confidencePercent}% confidence',
                  style: AppTheme.mono(size: 12, color: s.action.color)),
              const Spacer(),
              Text('P(up) ${(s.probabilityUp * 100).toStringAsFixed(0)}%',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ConfidenceBar(confidence: s.confidence, color: s.action.color),
          const SizedBox(height: 12),
          ...s.reasons.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      r.bullish ? Icons.add : Icons.remove,
                      size: 14,
                      color: r.bullish ? AppColors.up : AppColors.down,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(r.text,
                          style: AppTheme.bodyStyle.copyWith(fontSize: 12.5)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 6),
          Text('Tap for full indicator breakdown',
              style: AppTheme.labelStyle.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}
