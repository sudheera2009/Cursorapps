import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatting.dart';
import '../core/theme.dart';
import '../models/instrument.dart';
import '../providers/trading_provider.dart';
import '../widgets/change_pill.dart';
import '../widgets/instrument_tile.dart';
import '../widgets/panel_card.dart';
import 'instrument_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _filter = 0; // 0 all, 1 crude, 2 gas, 3 watchlist

  List<Instrument> _visible(TradingProvider p) {
    switch (_filter) {
      case 1:
        return Instruments.inSector(EnergySector.crude);
      case 2:
        return Instruments.inSector(EnergySector.gas);
      case 3:
        return Instruments.all.where((i) => p.isWatched(i.id)).toList();
      default:
        return Instruments.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TradingProvider>();
    final list = _visible(p);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Markets', style: AppTheme.headlineStyle),
                      const Spacer(),
                      _liveBadge(p),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Simulated energy futures · updates every second',
                      style: AppTheme.bodyStyle.copyWith(fontSize: 12)),
                  const SizedBox(height: 16),
                  _sectorSummary(p),
                  const SizedBox(height: 16),
                  _filters(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          if (list.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    _filter == 3
                        ? 'Your watchlist is empty.\nTap the star on any market to add it.'
                        : 'No markets.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyStyle,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
              sliver: SliverList.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.cardBorder,
                ),
                itemBuilder: (context, i) {
                  final inst = list[i];
                  return InstrumentTile(
                    instrument: inst,
                    quote: p.quote(inst.id),
                    held: p.positionFor(inst.id) != null,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            InstrumentScreen(instrumentId: inst.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _liveBadge(TradingProvider p) {
    return GestureDetector(
      onTap: p.toggleRunning,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (p.running ? AppColors.up : AppColors.neutral)
              .withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(p.running ? Icons.circle : Icons.pause,
                size: 9,
                color: p.running ? AppColors.up : AppColors.neutral),
            const SizedBox(width: 6),
            Text(p.running ? 'LIVE' : 'PAUSED',
                style: AppTheme.labelStyle.copyWith(
                  color: p.running ? AppColors.up : AppColors.neutral,
                  fontSize: 10,
                )),
          ],
        ),
      ),
    );
  }

  Widget _sectorSummary(TradingProvider p) {
    return Row(
      children: [
        Expanded(child: _sectorCard(p, EnergySector.crude, 'CL')),
        const SizedBox(width: 12),
        Expanded(child: _sectorCard(p, EnergySector.gas, 'NG')),
      ],
    );
  }

  Widget _sectorCard(TradingProvider p, EnergySector sector, String id) {
    final inst = Instruments.byId(id);
    final q = p.quote(id);
    return PanelCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => InstrumentScreen(instrumentId: id)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(inst.emoji),
              const SizedBox(width: 6),
              Text(sector.label,
                  style: AppTheme.labelStyle.copyWith(color: sector.color)),
            ],
          ),
          const SizedBox(height: 10),
          Text(Fmt.price(q.price, inst.tickSize),
              style: AppTheme.mono(size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          ChangePill(percent: q.changePercent),
        ],
      ),
    );
  }

  Widget _filters() {
    const labels = ['All', 'Crude', 'Gas', 'Watchlist'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _filter == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) => setState(() => _filter = i),
              labelStyle: AppTheme.bodyStyle.copyWith(
                color: selected ? Colors.black : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.card,
              side: const BorderSide(color: AppColors.cardBorder),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }
}
