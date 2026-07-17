import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/trade.dart';
import '../providers/trading_provider.dart';
import '../widgets/panel_card.dart';
import '../widgets/stat_box.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();
    final trades = p.trades;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Activity', style: AppTheme.headlineStyle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PanelCard(
                  child: StatBox(
                      label: 'Trades', value: '${p.tradeCount}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PanelCard(
                  child: StatBox(
                    label: 'Win rate',
                    value: p.closingTrades == 0
                        ? '—'
                        : '${p.winRate.toStringAsFixed(0)}%',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PanelCard(
                  child: StatBox(
                    label: 'Realized',
                    value: Fmt.signedMoney(p.realizedPnl),
                    valueColor: AppColors.forChange(p.realizedPnl),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Trade blotter', style: AppTheme.titleStyle),
          const SizedBox(height: 12),
          if (trades.isEmpty)
            PanelCard(
              padding:
                  const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No trades yet',
                      style: AppTheme.subtitleStyle
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Your executed orders will appear here.',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 13)),
                ],
              ),
            )
          else
            ...trades.map((t) => _tradeRow(t)),
        ],
      ),
    );
  }

  Widget _tradeRow(Trade t) {
    final inst = Instruments.byId(t.instrumentId);
    final isBuy = t.side == OrderSide.buy;
    final sideColor = isBuy ? AppColors.up : AppColors.down;
    final hasPnl = t.realizedPnl.abs() > 1e-6;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sideColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isBuy ? Icons.south_west : Icons.north_east,
              color: sideColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.side.label} ${inst.symbol}',
                  style: AppTheme.subtitleStyle
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text('${Fmt.lots(t.lots)} lots @ ${Fmt.price(t.price, inst.tickSize)}',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.money0(t.notional),
                  style: AppTheme.mono(size: 13)),
              const SizedBox(height: 2),
              if (hasPnl)
                Text(Fmt.signedMoney(t.realizedPnl),
                    style: AppTheme.mono(
                        size: 11,
                        color: AppColors.forChange(t.realizedPnl)))
              else
                Text(Fmt.timeAgo(t.timestamp),
                    style: AppTheme.bodyStyle.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
