import 'package:flutter_test/flutter_test.dart';

import 'package:barrel_trader/models/candle.dart';
import 'package:barrel_trader/models/market_context.dart';
import 'package:barrel_trader/models/trade_signal.dart';
import 'package:barrel_trader/services/indicators.dart';
import 'package:barrel_trader/services/signal_engine.dart';

List<Candle> candlesFromCloses(List<double> closes) {
  final now = DateTime(2026, 1, 1);
  return [
    for (int i = 0; i < closes.length; i++)
      Candle(
        time: now.add(Duration(minutes: i)),
        open: i == 0 ? closes[i] : closes[i - 1],
        high: closes[i] + 0.5,
        low: closes[i] - 0.5,
        close: closes[i],
        volume: 1000,
      ),
  ];
}

void main() {
  group('EMA / SMA', () {
    test('EMA seeds from the first value and is same length', () {
      final ema = Indicators.ema([1, 2, 3, 4, 5], 3);
      expect(ema.length, 5);
      expect(ema.first, 1);
      // EMA should trail below the last value in a rising series.
      expect(ema.last, lessThan(5));
      expect(ema.last, greaterThan(3));
    });

    test('SMA averages the last N', () {
      expect(Indicators.sma([2, 4, 6, 8], 2), closeTo(7, 1e-9));
    });
  });

  group('RSI', () {
    test('is 100 for a monotonically rising series', () {
      final closes = List<double>.generate(30, (i) => 100 + i.toDouble());
      expect(Indicators.rsi(closes), closeTo(100, 1e-6));
    });

    test('is low for a monotonically falling series', () {
      final closes = List<double>.generate(30, (i) => 100 - i.toDouble());
      expect(Indicators.rsi(closes), lessThan(5));
    });

    test('returns 50 without enough data', () {
      expect(Indicators.rsi([1, 2, 3]), 50);
    });
  });

  group('Bollinger', () {
    test('bands straddle the mean and %b is mid for flat series', () {
      final closes = List<double>.filled(25, 50);
      final (upper, mid, lower, pb, width) = Indicators.bollinger(closes);
      expect(mid, closeTo(50, 1e-9));
      expect(upper, closeTo(50, 1e-9));
      expect(lower, closeTo(50, 1e-9));
      expect(pb, closeTo(0.5, 1e-9));
      expect(width, closeTo(0, 1e-9));
    });
  });

  group('ATR / ADX / VWAP', () {
    test('ATR is positive with ranged candles', () {
      final candles = candlesFromCloses(
          List<double>.generate(40, (i) => 100 + (i % 5).toDouble()));
      expect(Indicators.atr(candles), greaterThan(0));
    });

    test('ADX signals a strong trend in a steady climb', () {
      final candles = candlesFromCloses(
          List<double>.generate(60, (i) => 100 + i.toDouble()));
      final (adx, plusDI, minusDI) = Indicators.adx(candles);
      expect(adx, greaterThan(20));
      expect(plusDI, greaterThan(minusDI));
    });

    test('VWAP equals price for constant volume & price', () {
      final candles = candlesFromCloses(List<double>.filled(20, 42));
      expect(Indicators.vwap(candles), closeTo(42, 1e-6));
    });
  });

  group('SignalEngine', () {
    test('emits BUY on a strong uptrend', () {
      final candles = candlesFromCloses(
          List<double>.generate(80, (i) => 100 + i * 0.8));
      final signal = SignalEngine().generate(
        instrumentId: 'CL',
        candles: candles,
        context: const MarketContext(newsSentiment: 0.5),
      );
      expect(signal.action, SignalAction.buy);
      expect(signal.probabilityUp, greaterThan(0.5));
      expect(signal.reasons, isNotEmpty);
    });

    test('emits SELL on a strong downtrend', () {
      final candles = candlesFromCloses(
          List<double>.generate(80, (i) => 200 - i * 0.8));
      final signal = SignalEngine().generate(
        instrumentId: 'NG',
        candles: candles,
        context: const MarketContext(newsSentiment: -0.5),
      );
      expect(signal.action, SignalAction.sell);
      expect(signal.probabilityUp, lessThan(0.5));
    });

    test('confidence is in 0..1', () {
      final candles = candlesFromCloses(
          List<double>.generate(80, (i) => 100 + i * 0.8));
      final signal =
          SignalEngine().generate(instrumentId: 'CL', candles: candles);
      expect(signal.confidence, inInclusiveRange(0.0, 1.0));
      expect(signal.confidencePercent, inInclusiveRange(0, 100));
    });
  });
}
