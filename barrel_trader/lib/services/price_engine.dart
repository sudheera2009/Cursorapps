import 'dart:math';

import '../models/candle.dart';
import '../models/instrument.dart';
import '../models/quote.dart';

class _Forming {
  double open;
  double high;
  double low;
  double close;
  double volume;
  int ticks;
  DateTime start;

  _Forming(this.open, this.start)
      : high = open,
        low = open,
        close = open,
        volume = 0,
        ticks = 0;

  void add(double price, double vol) {
    close = price;
    if (price > high) high = price;
    if (price < low) low = price;
    volume += vol;
    ticks++;
  }

  Candle toCandle() => Candle(
        time: start,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
}

/// Simulates a live energy market with both a tick-level price path and
/// aggregated OHLC + volume candles.
///
/// Prices follow a mean-reverting random walk (an Ornstein-Uhlenbeck style
/// process) so they wander realistically but never drift to absurd values.
/// This stands in for the "Market Data" node of the pipeline; see
/// [MarketDataSource] for how a real Zerodha Kite feed would slot in.
class PriceEngine {
  PriceEngine({Random? random}) : _rng = random ?? Random();

  final Random _rng;
  final Map<String, Quote> _quotes = {};
  final Map<String, List<Candle>> _candles = {};
  final Map<String, _Forming> _forming = {};

  /// Maximum number of tick points kept per instrument (line chart history).
  static const int historyLength = 180;

  /// Maximum number of candles retained per instrument.
  static const int candleHistory = 180;

  /// Ticks aggregated into a single candle bar.
  static const int ticksPerCandle = 3;

  static const double _meanReversion = 0.02;

  Map<String, Quote> get quotes => _quotes;

  Quote quoteFor(String id) => _quotes[id]!;

  /// Completed candles for [id]. When [includeForming] is true, the
  /// currently-forming bar is appended so indicators update intra-candle.
  List<Candle> candlesFor(String id, {bool includeForming = true}) {
    final base = _candles[id] ?? const <Candle>[];
    final forming = _forming[id];
    if (includeForming && forming != null && forming.ticks > 0) {
      return [...base, forming.toCandle()];
    }
    return List<Candle>.from(base);
  }

  /// Creates fresh quotes and candle history for every instrument.
  void initialize() {
    _quotes.clear();
    _candles.clear();
    _forming.clear();
    final now = DateTime.now();
    for (final inst in Instruments.all) {
      final candles = <Candle>[];
      double price = inst.basePrice;
      for (int c = 0; c < candleHistory; c++) {
        final open = _round(inst, price);
        double high = open, low = open, close = open, vol = 0;
        for (int t = 0; t < ticksPerCandle; t++) {
          final prev = price;
          price = _step(inst, price);
          final rounded = _round(inst, price);
          close = rounded;
          if (rounded > high) high = rounded;
          if (rounded < low) low = rounded;
          vol += _volume(inst, (rounded - prev).abs() / prev);
        }
        candles.add(Candle(
          time: now.subtract(
              Duration(minutes: (candleHistory - c) * ticksPerCandle)),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: vol,
        ));
      }
      _candles[inst.id] = candles;

      final history =
          candles.map((c) => c.close).toList(growable: true);
      final currentPrice = candles.last.close;
      _quotes[inst.id] = Quote(
        instrumentId: inst.id,
        price: currentPrice,
        sessionOpen: candles.first.open,
        dayHigh: candles.map((c) => c.high).reduce(max),
        dayLow: candles.map((c) => c.low).reduce(min),
        history: history,
      );
      _forming[inst.id] = _Forming(currentPrice, now);
    }
  }

  /// Advances every instrument one tick.
  void tick() {
    final now = DateTime.now();
    for (final inst in Instruments.all) {
      final q = _quotes[inst.id];
      final forming = _forming[inst.id];
      if (q == null || forming == null) continue;

      final prev = q.price;
      final next = _round(inst, _step(inst, prev));
      final vol = _volume(inst, (next - prev).abs() / prev);

      q.price = next;
      if (next > q.dayHigh) q.dayHigh = next;
      if (next < q.dayLow) q.dayLow = next;
      q.history.add(next);
      if (q.history.length > historyLength) q.history.removeAt(0);

      forming.add(next, vol);
      if (forming.ticks >= ticksPerCandle) {
        final list = _candles[inst.id]!;
        list.add(forming.toCandle());
        if (list.length > candleHistory) list.removeAt(0);
        _forming[inst.id] = _Forming(next, now);
      }
    }
  }

  double _step(Instrument inst, double price) {
    final shock = _gaussian() * inst.volatility * price;
    final drift = (inst.basePrice - price) * _meanReversion;
    final next = price + drift + shock;
    return max(inst.tickSize, next);
  }

  /// Synthetic volume: a base flow that swells with larger price moves.
  double _volume(Instrument inst, double movePct) {
    final base = 300 + _rng.nextDouble() * 400;
    return base * (1 + movePct * 60);
  }

  double _round(Instrument inst, double price) {
    final steps = (price / inst.tickSize).round();
    return steps * inst.tickSize;
  }

  double _gaussian() {
    final u1 = 1.0 - _rng.nextDouble();
    final u2 = 1.0 - _rng.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }
}
