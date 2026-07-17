/// An open position in one instrument.
///
/// [lots] is signed: positive is long, negative is short. [avgPrice] is the
/// volume-weighted average entry price. Cash accounting uses a fully-funded
/// (no-leverage) model, so opening a position locks its notional as cost basis
/// and closing releases that cost plus/minus realized P&L.
class Position {
  final String instrumentId;
  double lots; // signed
  double avgPrice;
  final double contractSize;

  Position({
    required this.instrumentId,
    required this.lots,
    required this.avgPrice,
    required this.contractSize,
  });

  bool get isLong => lots > 0;
  bool get isShort => lots < 0;
  bool get isFlat => lots == 0;
  double get absLots => lots.abs();

  String get directionLabel => isLong ? 'LONG' : (isShort ? 'SHORT' : 'FLAT');

  /// Cash locked as cost basis for this position.
  double get costBasis => absLots * avgPrice * contractSize;

  /// Cash returned if the position were fully closed at [price] right now.
  double releaseValue(double price) {
    if (isLong) return absLots * price * contractSize;
    // Short: get the margin back plus the favourable move.
    return costBasis + absLots * (avgPrice - price) * contractSize;
  }

  /// Current market value of the position for equity purposes.
  double marketValue(double price) => releaseValue(price);

  /// Unrealized profit/loss at [price].
  double unrealizedPnl(double price) =>
      lots * (price - avgPrice) * contractSize;

  /// Unrealized P&L as a percentage of cost basis.
  double unrealizedPnlPercent(double price) {
    if (costBasis == 0) return 0;
    return unrealizedPnl(price) / costBasis * 100;
  }

  Map<String, dynamic> toJson() => {
        'instrumentId': instrumentId,
        'lots': lots,
        'avgPrice': avgPrice,
        'contractSize': contractSize,
      };

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        instrumentId: json['instrumentId'] as String,
        lots: (json['lots'] as num).toDouble(),
        avgPrice: (json['avgPrice'] as num).toDouble(),
        contractSize: (json['contractSize'] as num).toDouble(),
      );
}
