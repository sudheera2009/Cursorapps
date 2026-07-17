import 'dart:math';

import '../models/candle.dart';
import '../models/quote.dart';
import 'price_engine.dart';

/// The "Market Data" node of the pipeline.
///
/// Abstracts where OHLC + volume comes from so the rest of the app (indicators,
/// prediction, signals) is agnostic to the source. The app ships with
/// [SimulatedMarketDataSource]; wire a real feed by implementing this interface
/// (see [KiteMarketDataSource] for the Zerodha Kite Connect shape).
abstract class MarketDataSource {
  String get name;

  /// True when backed by a live exchange feed rather than the simulator.
  bool get isLive;

  /// Prepares quotes + candle history for all instruments.
  void initialize();

  /// Advances the feed by one step (no-op for a push-based live feed).
  void tick();

  Quote quoteFor(String id);
  double priceOf(String id) => quoteFor(id).price;
  List<Candle> candlesFor(String id, {bool includeForming = true});
}

/// Default data source: an on-device market simulator.
class SimulatedMarketDataSource implements MarketDataSource {
  SimulatedMarketDataSource({Random? random})
      : _engine = PriceEngine(random: random);

  final PriceEngine _engine;

  @override
  String get name => 'Simulated feed';

  @override
  bool get isLive => false;

  @override
  void initialize() => _engine.initialize();

  @override
  void tick() => _engine.tick();

  @override
  Quote quoteFor(String id) => _engine.quoteFor(id);

  @override
  double priceOf(String id) => _engine.quoteFor(id).price;

  @override
  List<Candle> candlesFor(String id, {bool includeForming = true}) =>
      _engine.candlesFor(id, includeForming: includeForming);
}

/// Zerodha Kite Connect adapter (integration stub).
///
/// To make BARREL trade against live Indian energy contracts (MCX crude oil,
/// natural gas), implement this against the `kiteconnect` Dart package or the
/// Kite HTTP API:
///
/// * **Auth**: exchange your `api_key` + `request_token` for an `access_token`
///   (`POST /session/token`).
/// * **Historical OHLC + volume** ([candlesFor]): `GET /instruments/historical/
///   {instrument_token}/{interval}` → map each row to a [Candle].
/// * **Live quotes** ([quoteFor]): either poll `GET /quote` or subscribe to the
///   Kite Ticker websocket and update the cached [Quote] on each tick.
///
/// Credentials should be supplied via secure configuration (never hard-coded).
class KiteMarketDataSource implements MarketDataSource {
  KiteMarketDataSource({
    required this.apiKey,
    required this.accessToken,
    required this.instrumentTokens,
  });

  final String apiKey;
  final String accessToken;

  /// Maps BARREL instrument ids (e.g. "CL") to Kite instrument tokens.
  final Map<String, int> instrumentTokens;

  @override
  String get name => 'Zerodha Kite';

  @override
  bool get isLive => true;

  Never _notImplemented() => throw UnimplementedError(
        'KiteMarketDataSource is an integration stub. Implement it against the '
        'Kite Connect API using apiKey/accessToken and instrumentTokens.',
      );

  @override
  void initialize() => _notImplemented();

  @override
  void tick() => _notImplemented();

  @override
  Quote quoteFor(String id) => _notImplemented();

  @override
  double priceOf(String id) => _notImplemented();

  @override
  List<Candle> candlesFor(String id, {bool includeForming = true}) =>
      _notImplemented();
}
