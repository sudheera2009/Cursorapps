import 'dart:math';

import '../models/instrument.dart';
import '../models/quote.dart';

/// Simulates a live energy market.
///
/// Prices follow a mean-reverting random walk (an Ornstein-Uhlenbeck style
/// process) so they wander realistically but never drift to absurd values over
/// a long session. This is deliberately self-contained: BARREL is a paper
/// trading simulator and does not connect to any live exchange feed.
class PriceEngine {
  PriceEngine({Random? random}) : _rng = random ?? Random();

  final Random _rng;
  final Map<String, Quote> _quotes = {};

  /// Maximum number of history points kept per instrument.
  static const int historyLength = 180;

  /// Strength of pull back toward the anchor price each tick.
  static const double _meanReversion = 0.02;

  Map<String, Quote> get quotes => _quotes;

  Quote quoteFor(String id) => _quotes[id]!;

  /// Creates fresh quotes for every instrument and backfills a plausible
  /// price history so charts have something to draw immediately.
  void initialize({int backfill = historyLength}) {
    _quotes.clear();
    for (final inst in Instruments.all) {
      final history = _backfill(inst, backfill);
      final price = history.last;
      _quotes[inst.id] = Quote(
        instrumentId: inst.id,
        price: price,
        sessionOpen: history.first,
        dayHigh: history.reduce(max),
        dayLow: history.reduce(min),
        history: history,
      );
    }
  }

  List<double> _backfill(Instrument inst, int count) {
    final out = <double>[];
    double price = inst.basePrice;
    for (int i = 0; i < count; i++) {
      price = _step(inst, price);
      out.add(_round(inst, price));
    }
    return out;
  }

  /// Advances every instrument one tick.
  void tick() {
    for (final inst in Instruments.all) {
      final q = _quotes[inst.id];
      if (q == null) continue;
      final next = _round(inst, _step(inst, q.price));
      q.price = next;
      if (next > q.dayHigh) q.dayHigh = next;
      if (next < q.dayLow) q.dayLow = next;
      q.history.add(next);
      if (q.history.length > historyLength) {
        q.history.removeAt(0);
      }
    }
  }

  double _step(Instrument inst, double price) {
    // Gaussian shock scaled by the instrument's volatility.
    final shock = _gaussian() * inst.volatility * price;
    // Gentle pull toward the anchor (base) price.
    final drift = (inst.basePrice - price) * _meanReversion;
    final next = price + drift + shock;
    return max(inst.tickSize, next);
  }

  double _round(Instrument inst, double price) {
    final steps = (price / inst.tickSize).round();
    return steps * inst.tickSize;
  }

  /// Box-Muller transform for a standard normal sample.
  double _gaussian() {
    final u1 = 1.0 - _rng.nextDouble();
    final u2 = 1.0 - _rng.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }
}
