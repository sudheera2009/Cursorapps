/// A single OHLC + volume bar.
///
/// This is the fundamental unit consumed by the technical indicator engine.
/// In the live app, candles are produced by the [PriceEngine]; a real
/// deployment would populate them from Zerodha Kite historical OHLC data.
class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  /// Typical price (HLC/3), used by VWAP and other indicators.
  double get typical => (high + low + close) / 3;

  bool get isUp => close >= open;

  Map<String, dynamic> toJson() => {
        't': time.toIso8601String(),
        'o': open,
        'h': high,
        'l': low,
        'c': close,
        'v': volume,
      };

  factory Candle.fromJson(Map<String, dynamic> json) => Candle(
        time: DateTime.parse(json['t'] as String),
        open: (json['o'] as num).toDouble(),
        high: (json['h'] as num).toDouble(),
        low: (json['l'] as num).toDouble(),
        close: (json['c'] as num).toDouble(),
        volume: (json['v'] as num).toDouble(),
      );
}
