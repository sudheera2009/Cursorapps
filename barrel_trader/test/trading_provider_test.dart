import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:barrel_trader/models/trade.dart';
import 'package:barrel_trader/providers/trading_provider.dart';
import 'package:barrel_trader/services/price_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<TradingProvider> freshProvider() async {
    SharedPreferences.setMockInitialValues({});
    final p = TradingProvider(
      engine: PriceEngine(random: Random(1)),
      // Long interval so the timer never fires during a test.
      tickInterval: const Duration(hours: 1),
    );
    await p.initialize();
    p.pause();
    return p;
  }

  test('starts flat with the initial deposit', () async {
    final p = await freshProvider();
    expect(p.cash, TradingProvider.startingCash);
    expect(p.equity, closeTo(TradingProvider.startingCash, 1e-6));
    expect(p.openPositions, isEmpty);
    expect(p.totalPnl, closeTo(0, 1e-6));
  });

  test('buying opens a long and locks cash without changing equity', () async {
    final p = await freshProvider();
    final priceBefore = p.priceOf('CL');
    final r = p.placeOrder('CL', OrderSide.buy, 2);
    expect(r.success, true);

    final pos = p.positionFor('CL');
    expect(pos, isNotNull);
    expect(pos!.isLong, true);
    expect(pos.absLots, 2);
    // Cash dropped by the notional...
    expect(p.cash, closeTo(TradingProvider.startingCash - priceBefore * 100 * 2, 1e-6));
    // ...but equity is unchanged at the moment of the fill.
    expect(p.equity, closeTo(TradingProvider.startingCash, 1e-6));
  });

  test('closing a long realizes P&L into cash', () async {
    final p = await freshProvider();
    p.placeOrder('CL', OrderSide.buy, 1);
    final entry = p.positionFor('CL')!.avgPrice;

    // Move the market up deterministically for a known profit.
    final q = p.quote('CL');
    q.price = entry + 3; // +$3 * 100 size = +$300
    q.history.add(q.price);

    final r = p.closePosition('CL');
    expect(r.success, true);
    expect(p.positionFor('CL'), isNull);
    expect(p.realizedPnl, closeTo(300, 1e-6));
    expect(p.cash, closeTo(TradingProvider.startingCash + 300, 1e-6));
  });

  test('shorting then covering lower is profitable', () async {
    final p = await freshProvider();
    p.placeOrder('NG', OrderSide.sell, 2);
    final pos = p.positionFor('NG')!;
    expect(pos.isShort, true);

    final q = p.quote('NG');
    q.price = pos.avgPrice - 0.10; // gas contract size 1000 => +$0.10*1000*2 = $200
    q.history.add(q.price);

    p.closePosition('NG');
    expect(p.realizedPnl, closeTo(200, 1e-6));
  });

  test('rejects orders that exceed buying power', () async {
    final p = await freshProvider();
    // 10,000 lots of CL is astronomically more than $100k of cash.
    final r = p.placeOrder('CL', OrderSide.buy, 10000);
    expect(r.success, false);
    expect(p.positionFor('CL'), isNull);
    expect(p.cash, TradingProvider.startingCash);
  });

  test('reset restores the account to its initial state', () async {
    final p = await freshProvider();
    p.placeOrder('CL', OrderSide.buy, 1);
    await p.resetAccount();
    expect(p.cash, TradingProvider.startingCash);
    expect(p.openPositions, isEmpty);
    expect(p.trades, isEmpty);
  });
}
