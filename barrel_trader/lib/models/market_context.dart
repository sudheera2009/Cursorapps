/// Fundamental (non-price) inputs for an instrument, feeding the prediction
/// layer alongside technical indicators.
///
/// All scores are normalised to the range -1..1 where **positive is
/// price-supportive (bullish)** and negative is bearish.
class MarketContext {
  /// Aggregated news/social sentiment (-1 very bearish .. +1 very bullish).
  final double newsSentiment;

  /// Number of headlines the sentiment was aggregated from.
  final int headlineCount;

  /// EIA inventory surprise vs consensus. Positive = a bullish surprise
  /// (e.g. a larger-than-expected crude draw or gas withdrawal).
  final double inventorySurprise;

  /// Weather-driven demand signal. Positive = demand-supportive
  /// (e.g. a cold snap lifting heating/gas demand).
  final double weatherFactor;

  const MarketContext({
    this.newsSentiment = 0,
    this.headlineCount = 0,
    this.inventorySurprise = 0,
    this.weatherFactor = 0,
  });

  static const MarketContext neutral = MarketContext();

  /// Blended fundamental score in -1..1 used by the prediction model.
  double get fundamentalScore {
    final s = newsSentiment * 0.5 +
        inventorySurprise * 0.3 +
        weatherFactor * 0.2;
    return s.clamp(-1.0, 1.0);
  }

  String get sentimentLabel {
    if (newsSentiment > 0.33) return 'Bullish';
    if (newsSentiment < -0.33) return 'Bearish';
    return 'Neutral';
  }
}
