import 'dart:math';

import '../models/instrument.dart';
import '../models/market_context.dart';

/// Supplies fundamental [MarketContext] for an instrument.
///
/// This is the seam where the pipeline's **News Sentiment** and
/// **Weather / EIA** nodes attach. The app ships with a
/// [SimulatedContextProvider]; production implementations would call:
///
/// * a news API + sentiment/NLP model (e.g. headlines → sentiment score), and
/// * the EIA petroleum/natural-gas storage reports + a weather API
///   (heating/cooling degree days) for the demand signal.
abstract class ContextProvider {
  MarketContext contextFor(String instrumentId);

  /// Advances any time-varying state (called periodically by the app).
  void tick() {}
}

/// A deterministic-per-session context source used for the demo/simulation.
///
/// Each instrument gets a slowly drifting sentiment, inventory surprise and
/// weather factor so the fundamental layer visibly influences signals without
/// needing live data feeds.
class SimulatedContextProvider implements ContextProvider {
  SimulatedContextProvider({Random? random}) : _rng = random ?? Random() {
    for (final inst in Instruments.all) {
      _sentiment[inst.id] = _rand();
      _inventory[inst.id] = _rand();
      _weather[inst.id] = _rand();
      _headlines[inst.id] = 4 + _rng.nextInt(30);
    }
  }

  final Random _rng;
  final Map<String, double> _sentiment = {};
  final Map<String, double> _inventory = {};
  final Map<String, double> _weather = {};
  final Map<String, int> _headlines = {};

  double _rand() => (_rng.nextDouble() * 2 - 1);

  /// Random walk clamped to -1..1.
  double _drift(double v) =>
      (v + (_rng.nextDouble() * 2 - 1) * 0.06).clamp(-1.0, 1.0);

  @override
  void tick() {
    for (final id in _sentiment.keys) {
      _sentiment[id] = _drift(_sentiment[id]!);
      _inventory[id] = _drift(_inventory[id]!);
      _weather[id] = _drift(_weather[id]!);
    }
  }

  @override
  MarketContext contextFor(String instrumentId) {
    final inst = Instruments.byId(instrumentId);
    // Weather matters most for natural gas; least for refined products.
    final weatherWeight = switch (inst.sector) {
      EnergySector.gas => 1.0,
      EnergySector.crude => 0.4,
      EnergySector.refined => 0.6,
    };
    return MarketContext(
      newsSentiment: _sentiment[instrumentId] ?? 0,
      headlineCount: _headlines[instrumentId] ?? 0,
      inventorySurprise: _inventory[instrumentId] ?? 0,
      weatherFactor: (_weather[instrumentId] ?? 0) * weatherWeight,
    );
  }
}
