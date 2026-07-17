import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/position.dart';
import '../providers/trading_provider.dart';
import '../widgets/panel_card.dart';
import '../widgets/stat_box.dart';
import 'instrument_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();
    final positions = p.openPositions;
    final totalPnlColor = AppColors.forChange(p.totalPnl);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Portfolio', style: AppTheme.headlineStyle),
          const SizedBox(height: 16),
          _equityCard(p, totalPnlColor),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PanelCard(
                  child: StatBox(
                    label: 'Open P&L',
                    value: Fmt.signedMoney(p.openPnl),
                    valueColor: AppColors.forChange(p.openPnl),
                    icon: Icons.trending_up,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PanelCard(
                  child: StatBox(
                    label: 'Realized P&L',
                    value: Fmt.signedMoney(p.realizedPnl),
                    valueColor: AppColors.forChange(p.realizedPnl),
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Open positions', style: AppTheme.titleStyle),
              const Spacer(),
              Text('${positions.length}',
                  style: AppTheme.mono(size: 15, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (positions.isEmpty)
            _emptyPositions()
          else
            ...positions.map((pos) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _positionCard(context, p, pos),
                )),
        ],
      ),
    );
  }

  Widget _equityCard(TradingProvider p, Color pnlColor) {
    return PanelCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACCOUNT EQUITY', style: AppTheme.labelStyle),
          const SizedBox(height: 8),
          Text(
            Fmt.money2(p.equity),
            style: AppTheme.mono(size: 34, weight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                p.totalPnl >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                size: 15,
                color: pnlColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${Fmt.signedMoney(p.totalPnl)}  (${Fmt.signedPercent(p.totalPnlPercent)})',
                style: AppTheme.mono(
                    size: 14, weight: FontWeight.w700, color: pnlColor),
              ),
              Text('  all time', style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: StatBox(
                    label: 'Free cash', value: Fmt.money2(p.cash)),
              ),
              Expanded(
                child: StatBox(
                    label: 'Invested', value: Fmt.money2(p.investedCapital)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _positionCard(BuildContext context, TradingProvider p, Position pos) {
    final inst = Instruments.byId(pos.instrumentId);
    final price = p.priceOf(pos.instrumentId);
    final pnl = pos.unrealizedPnl(price);
    final pnlColor = AppColors.forChange(pnl);
    final dirColor = pos.isLong ? AppColors.up : AppColors.down;

    return PanelCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InstrumentScreen(instrumentId: pos.instrumentId),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(inst.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(inst.symbol, style: AppTheme.titleStyle),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: dirColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${pos.directionLabel} ${Fmt.lots(pos.absLots)}',
                          style: AppTheme.labelStyle
                              .copyWith(color: dirColor, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Entry ${Fmt.price(pos.avgPrice, inst.tickSize)}',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Fmt.signedMoney(pnl),
                      style: AppTheme.mono(
                          size: 15,
                          weight: FontWeight.w700,
                          color: pnlColor)),
                  const SizedBox(height: 2),
                  Text(Fmt.signedPercent(pos.unrealizedPnlPercent(price)),
                      style: AppTheme.mono(size: 12, color: pnlColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _mini('Mark', Fmt.price(price, inst.tickSize)),
              ),
              Expanded(
                child: _mini('Value', Fmt.money0(pos.marketValue(price))),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final r = p.closePosition(pos.instrumentId);
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(SnackBar(
                        content: Text(r.message),
                        behavior: SnackBarBehavior.floating,
                      ));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 9)),
        const SizedBox(height: 3),
        Text(value, style: AppTheme.mono(size: 13)),
      ],
    );
  }

  Widget _emptyPositions() {
    return PanelCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No open positions',
              style: AppTheme.subtitleStyle
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Head to Markets and place your first trade.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyStyle.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
