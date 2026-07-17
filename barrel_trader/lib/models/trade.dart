/// Which way a trade goes.
enum OrderSide { buy, sell }

extension OrderSideX on OrderSide {
  String get label => this == OrderSide.buy ? 'Buy' : 'Sell';
  String get verb => this == OrderSide.buy ? 'Bought' : 'Sold';
}

/// A single executed fill in the trade blotter.
class Trade {
  final String id;
  final String instrumentId;
  final OrderSide side;
  final double lots;
  final double price;
  final double contractSize;
  final DateTime timestamp;

  /// Realized profit/loss booked by this fill (0 for pure opening trades).
  final double realizedPnl;

  Trade({
    required this.id,
    required this.instrumentId,
    required this.side,
    required this.lots,
    required this.price,
    required this.contractSize,
    required this.timestamp,
    this.realizedPnl = 0,
  });

  double get notional => price * contractSize * lots;

  Map<String, dynamic> toJson() => {
        'id': id,
        'instrumentId': instrumentId,
        'side': side.name,
        'lots': lots,
        'price': price,
        'contractSize': contractSize,
        'timestamp': timestamp.toIso8601String(),
        'realizedPnl': realizedPnl,
      };

  factory Trade.fromJson(Map<String, dynamic> json) => Trade(
        id: json['id'] as String,
        instrumentId: json['instrumentId'] as String,
        side: OrderSide.values.firstWhere(
          (s) => s.name == json['side'],
          orElse: () => OrderSide.buy,
        ),
        lots: (json['lots'] as num).toDouble(),
        price: (json['price'] as num).toDouble(),
        contractSize: (json['contractSize'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
        realizedPnl: (json['realizedPnl'] as num?)?.toDouble() ?? 0,
      );
}
