import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../models/trade.dart';
import '../providers/trading_provider.dart';

/// A modal bottom sheet used to place buy/sell orders for one instrument.
class TradeTicket extends StatefulWidget {
  final Instrument instrument;
  final OrderSide initialSide;

  const TradeTicket({
    super.key,
    required this.instrument,
    this.initialSide = OrderSide.buy,
  });

  static Future<void> show(
    BuildContext context,
    Instrument instrument, {
    OrderSide side = OrderSide.buy,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TradeTicket(instrument: instrument, initialSide: side),
    );
  }

  @override
  State<TradeTicket> createState() => _TradeTicketState();
}

class _TradeTicketState extends State<TradeTicket> {
  late OrderSide _side;
  double _lots = 1;

  @override
  void initState() {
    super.initState();
    _side = widget.initialSide;
  }

  void _adjust(double delta) {
    setState(() => _lots = (_lots + delta).clamp(1, 999));
  }

  void _submit(TradingProvider p) {
    final result = p.placeOrder(widget.instrument.id, _side, _lots);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success
              ? (_side == OrderSide.buy ? AppColors.up : AppColors.down)
                  .withValues(alpha: 0.9)
              : AppColors.cardAlt,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final inst = widget.instrument;
    final p = context.watch<TradingProvider>();
    final price = p.priceOf(inst.id);
    final notional = price * inst.contractSize * _lots;
    final position = p.positionFor(inst.id);
    final sideColor = _side == OrderSide.buy ? AppColors.up : AppColors.down;
    final canAfford = notional <= p.cash + 1e-6;
    // Selling/closing an existing long (or buying to cover a short) is always
    // allowed regardless of free cash because it reduces exposure.
    final reducesExposure = position != null &&
        ((position.isLong && _side == OrderSide.sell) ||
            (position.isShort && _side == OrderSide.buy));
    final affordable = canAfford || reducesExposure;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(inst.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${inst.symbol} · ${inst.name}',
                        style: AppTheme.titleStyle),
                    Text('1 lot = ${inst.contractLabel}',
                        style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Text(
                  Fmt.price(price, inst.tickSize),
                  style: AppTheme.mono(size: 20, weight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _sideToggle(),
            const SizedBox(height: 18),
            Text('LOTS', style: AppTheme.labelStyle),
            const SizedBox(height: 8),
            _lotStepper(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 5, 10, 25]
                  .map((n) => _quickLot(n.toDouble()))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _summaryRow('Order value', Fmt.money2(notional)),
            const SizedBox(height: 6),
            _summaryRow('Free cash', Fmt.money2(p.cash)),
            if (position != null) ...[
              const SizedBox(height: 6),
              _summaryRow('Current position',
                  '${position.directionLabel} ${Fmt.lots(position.absLots)}'),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: affordable ? () => _submit(p) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: sideColor,
                  disabledBackgroundColor: AppColors.cardAlt,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  affordable
                      ? '${_side.label} ${Fmt.lots(_lots)} ${inst.symbol}'
                      : 'Insufficient buying power',
                  style: AppTheme.titleStyle.copyWith(
                    color: affordable ? Colors.black : AppColors.textMuted,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sideToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _sideButton(OrderSide.buy, 'BUY / LONG', AppColors.up),
          _sideButton(OrderSide.sell, 'SELL / SHORT', AppColors.down),
        ],
      ),
    );
  }

  Widget _sideButton(OrderSide side, String label, Color color) {
    final selected = _side == side;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _side = side),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.labelStyle.copyWith(
              color: selected ? color : AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _lotStepper() {
    return Row(
      children: [
        _stepButton(Icons.remove, () => _adjust(-1)),
        Expanded(
          child: Text(
            Fmt.lots(_lots),
            textAlign: TextAlign.center,
            style: AppTheme.mono(size: 28, weight: FontWeight.w700),
          ),
        ),
        _stepButton(Icons.add, () => _adjust(1)),
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _quickLot(double n) {
    return ActionChip(
      label: Text('${Fmt.lots(n)} lots'),
      labelStyle: AppTheme.bodyStyle.copyWith(fontSize: 12),
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.cardBorder),
      onPressed: () => setState(() => _lots = n),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyStyle),
        Text(value, style: AppTheme.mono(size: 14)),
      ],
    );
  }
}
