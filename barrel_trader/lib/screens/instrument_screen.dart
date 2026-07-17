import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/position.dart';
import '../models/trade.dart';
import '../providers/trading_provider.dart';
import '../widgets/change_pill.dart';
import '../widgets/panel_card.dart';
import '../widgets/price_chart.dart';
import 'trade_ticket.dart';

class InstrumentScreen extends StatelessWidget {
  final String instrumentId;

  const InstrumentScreen({super.key, required this.instrumentId});

  @override
  Widget build(BuildContext context) {
    final inst = Instruments.byId(instrumentId);
    final p = context.watch<TradingProvider>();
    final quote = p.quote(instrumentId);
    final position = p.positionFor(instrumentId);
    final color = AppColors.forChange(quote.change);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(inst.emoji),
            const SizedBox(width: 8),
            Text(inst.symbol),
            const SizedBox(width: 8),
            Text(
              inst.sector.label,
              style: AppTheme.labelStyle.copyWith(color: inst.color),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: p.isWatched(instrumentId)
                ? 'Remove from watchlist'
                : 'Add to watchlist',
            icon: Icon(
              p.isWatched(instrumentId) ? Icons.star : Icons.star_border,
              color: p.isWatched(instrumentId)
                  ? AppColors.crude
                  : AppColors.textMuted,
            ),
            onPressed: () => p.toggleWatch(instrumentId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.price(quote.price, inst.tickSize),
                style: AppTheme.mono(size: 40, weight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(inst.quoteUnit,
                    style: AppTheme.bodyStyle.copyWith(fontSize: 13)),
              ),
              const Spacer(),
              ChangePill(percent: quote.changePercent, fontSize: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${Fmt.signedMoney(quote.change * inst.contractSize)} per lot today',
            style: AppTheme.bodyStyle.copyWith(color: color, fontSize: 13),
          ),
          const SizedBox(height: 20),
          PanelCard(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PriceChart(
                    data: quote.history,
                    color: color,
                    markerPrice: position?.avgPrice,
                    markerColor: AppColors.textSecondary,
                  ),
                ),
                if (position != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 0,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.textSecondary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your entry ${Fmt.price(position.avgPrice, inst.tickSize)}',
                          style: AppTheme.bodyStyle.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sessionStats(inst, p),
          const SizedBox(height: 16),
          if (position != null) _positionCard(context, inst, p, position),
          const SizedBox(height: 16),
          _contractCard(inst),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _tradeButton(
                  context,
                  inst,
                  OrderSide.buy,
                  'BUY / LONG',
                  AppColors.up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _tradeButton(
                  context,
                  inst,
                  OrderSide.sell,
                  'SELL / SHORT',
                  AppColors.down,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tradeButton(
    BuildContext context,
    Instrument inst,
    OrderSide side,
    String label,
    Color color,
  ) {
    return FilledButton(
      onPressed: () => TradeTicket.show(context, inst, side: side),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: AppTheme.labelStyle.copyWith(color: Colors.black, fontSize: 13),
      ),
    );
  }

  Widget _sessionStats(Instrument inst, TradingProvider p) {
    final q = p.quote(inst.id);
    return PanelCard(
      child: Column(
        children: [
          _statRow('Session open', Fmt.price(q.sessionOpen, inst.tickSize)),
          const Divider(height: 20),
          _statRow('Day high', Fmt.price(q.dayHigh, inst.tickSize)),
          const Divider(height: 20),
          _statRow('Day low', Fmt.price(q.dayLow, inst.tickSize)),
          const SizedBox(height: 14),
          _rangeBar(q.dayRangePosition, inst.color),
        ],
      ),
    );
  }

  Widget _rangeBar(double pos, Color color) {
    return LayoutBuilder(builder: (context, c) {
      return Stack(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Positioned(
            left: (c.maxWidth - 10) * pos,
            child: Container(
              width: 10,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _positionCard(BuildContext context, Instrument inst,
      TradingProvider p, Position position) {
    final price = p.priceOf(inst.id);
    final pnl = position.unrealizedPnl(price);
    final pnlColor = AppColors.forChange(pnl);
    return PanelCard(
      borderColor: pnlColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('YOUR POSITION', style: AppTheme.labelStyle),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (position.isLong ? AppColors.up : AppColors.down)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${position.directionLabel} ${Fmt.lots(position.absLots)}',
                  style: AppTheme.labelStyle.copyWith(
                    color: position.isLong ? AppColors.up : AppColors.down,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                    'Avg entry', Fmt.price(position.avgPrice, inst.tickSize)),
              ),
              Expanded(
                child: _miniStat('Unrealized P&L', Fmt.signedMoney(pnl),
                    color: pnlColor),
              ),
              Expanded(
                child: _miniStat(
                  'Return',
                  Fmt.signedPercent(position.unrealizedPnlPercent(price)),
                  color: pnlColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final r = p.closePosition(inst.id);
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(SnackBar(
                    content: Text(r.message),
                    behavior: SnackBarBehavior.floating,
                  ));
              },
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Close position'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contractCard(Instrument inst) {
    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTRACT SPECS', style: AppTheme.labelStyle),
          const SizedBox(height: 12),
          _statRow('Contract size', inst.contractLabel),
          const Divider(height: 20),
          _statRow('Sector', inst.sector.label),
          const Divider(height: 20),
          _statRow('Tick size', inst.tickSize.toString()),
          const Divider(height: 20),
          _statRow('Quote unit', inst.quoteUnit.replaceAll('/ ', 'per ')),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyStyle),
        Text(value, style: AppTheme.mono(size: 14)),
      ],
    );
  }

  Widget _miniStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelStyle.copyWith(fontSize: 9)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTheme.mono(
                size: 14, weight: FontWeight.w700, color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}
