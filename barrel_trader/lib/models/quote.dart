/// Live (simulated) market data for one instrument.
///
/// A [Quote] is mutable and updated in place by the price engine on every tick.
/// It keeps a rolling in-memory price history used to draw sparklines and
/// charts, plus the day's session statistics.
class Quote {
  final String instrumentId;
  double price;
  final double sessionOpen;
  double dayHigh;
  double dayLow;

  /// Rolling price history (oldest first). Capped by the engine.
  final List<double> history;

  Quote({
    required this.instrumentId,
    required this.price,
    required this.sessionOpen,
    required this.dayHigh,
    required this.dayLow,
    List<double>? history,
  }) : history = history ?? <double>[price];

  /// Absolute change vs the session open.
  double get change => price - sessionOpen;

  /// Percentage change vs the session open.
  double get changePercent =>
      sessionOpen == 0 ? 0 : (price - sessionOpen) / sessionOpen * 100;

  bool get isUp => change > 0;
  bool get isDown => change < 0;

  /// Where the current price sits within the day's range, 0..1.
  double get dayRangePosition {
    final span = dayHigh - dayLow;
    if (span <= 0) return 0.5;
    return ((price - dayLow) / span).clamp(0.0, 1.0);
  }
}
