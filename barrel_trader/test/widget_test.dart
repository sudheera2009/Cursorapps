import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barrel_trader/models/instrument.dart';
import 'package:barrel_trader/models/position.dart';
import 'package:barrel_trader/models/quote.dart';
import 'package:barrel_trader/models/trade.dart';
import 'package:barrel_trader/services/price_engine.dart';
import 'package:barrel_trader/widgets/sparkline.dart';

void main() {
  group('Instruments', () {
    test('exposes crude and natural gas markets', () {
      expect(Instruments.all.length, greaterThanOrEqualTo(4));
      expect(Instruments.inSector(EnergySector.crude), isNotEmpty);
      expect(Instruments.inSector(EnergySector.gas), isNotEmpty);
      // Core WTI + Henry Hub gas must be present.
      expect(Instruments.byId('CL').name, contains('WTI'));
      expect(Instruments.byId('NG').sector, EnergySector.gas);
    });

    test('byId falls back to first instrument for unknown ids', () {
      expect(Instruments.byId('nope').id, Instruments.all.first.id);
    });
  });

  group('Quote', () {
    test('computes change and percent vs session open', () {
      final q = Quote(
        instrumentId: 'CL',
        price: 80,
        sessionOpen: 78,
        dayHigh: 81,
        dayLow: 77,
      );
      expect(q.change, closeTo(2, 1e-9));
      expect(q.changePercent, closeTo(2 / 78 * 100, 1e-9));
      expect(q.isUp, true);
      expect(q.dayRangePosition, closeTo(0.75, 1e-9));
    });
  });

  group('Position P&L', () {
    test('long position gains when price rises', () {
      final p = Position(
          instrumentId: 'CL', lots: 2, avgPrice: 70, contractSize: 100);
      // +$5 move * 100 size * 2 lots = +$1000.
      expect(p.unrealizedPnl(75), closeTo(1000, 1e-9));
      expect(p.costBasis, closeTo(2 * 70 * 100, 1e-9));
      expect(p.releaseValue(75), closeTo(2 * 75 * 100, 1e-9));
    });

    test('short position gains when price falls', () {
      final p = Position(
          instrumentId: 'CL', lots: -2, avgPrice: 70, contractSize: 100);
      // -$5 move on a short of 2 lots = +$1000.
      expect(p.unrealizedPnl(65), closeTo(1000, 1e-9));
      // Releasing at a lower price returns cost basis + profit.
      expect(p.releaseValue(65), closeTo(p.costBasis + 1000, 1e-9));
    });

    test('serializes round-trip', () {
      final p = Position(
          instrumentId: 'NG', lots: -1.5, avgPrice: 2.8, contractSize: 1000);
      final restored = Position.fromJson(p.toJson());
      expect(restored.lots, p.lots);
      expect(restored.avgPrice, p.avgPrice);
      expect(restored.isShort, true);
    });
  });

  group('Trade', () {
    test('serializes round-trip', () {
      final t = Trade(
        id: 'x1',
        instrumentId: 'CL',
        side: OrderSide.sell,
        lots: 3,
        price: 79.5,
        contractSize: 100,
        timestamp: DateTime(2026, 1, 2, 3, 4),
        realizedPnl: 250,
      );
      final r = Trade.fromJson(t.toJson());
      expect(r.side, OrderSide.sell);
      expect(r.notional, closeTo(79.5 * 100 * 3, 1e-9));
      expect(r.realizedPnl, 250);
    });
  });

  group('PriceEngine', () {
    test('initializes quotes for every instrument with history', () {
      final engine = PriceEngine(random: Random(42));
      engine.initialize();
      for (final inst in Instruments.all) {
        final q = engine.quoteFor(inst.id);
        expect(q.history.length, PriceEngine.historyLength);
        expect(q.price, greaterThan(0));
      }
    });

    test('tick keeps history capped and prices positive', () {
      final engine = PriceEngine(random: Random(7));
      engine.initialize();
      for (int i = 0; i < 50; i++) {
        engine.tick();
      }
      final q = engine.quoteFor('NG');
      expect(q.history.length, PriceEngine.historyLength);
      expect(q.price, greaterThan(0));
      expect(q.dayHigh, greaterThanOrEqualTo(q.dayLow));
    });
  });

  testWidgets('Sparkline renders without error', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 100,
          height: 40,
          child: Sparkline(data: [1, 2, 1.5, 3, 2.5], color: Colors.green),
        ),
      ),
    ));
    expect(find.byType(Sparkline), findsOneWidget);
  });
}
