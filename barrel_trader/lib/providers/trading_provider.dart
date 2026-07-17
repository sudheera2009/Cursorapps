import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/instrument.dart';
import '../models/position.dart';
import '../models/quote.dart';
import '../models/trade.dart';
import '../services/price_engine.dart';

/// Outcome of attempting to place an order.
class OrderResult {
  final bool success;
  final String message;
  final Trade? trade;

  const OrderResult(this.success, this.message, [this.trade]);
}

/// Single source of truth for BARREL: the simulated market, the paper trading
/// account, and persistence of both across launches.
class TradingProvider extends ChangeNotifier {
  TradingProvider({PriceEngine? engine, this.tickInterval = const Duration(seconds: 1)})
      : _engine = engine ?? PriceEngine();

  final PriceEngine _engine;
  final Duration tickInterval;
  Timer? _timer;

  static const double startingCash = 100000;
  static const double _eps = 1e-6;

  double _cash = startingCash;
  double _realizedPnl = 0;
  double _peakEquity = startingCash;
  DateTime _createdAt = DateTime.now();
  final Map<String, Position> _positions = {};
  final List<Trade> _trades = [];
  Set<String> _watchlist = Instruments.all.map((i) => i.id).toSet();
  bool _ready = false;
  bool _running = false;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  bool get ready => _ready;
  bool get running => _running;
  double get cash => _cash;
  double get realizedPnl => _realizedPnl;
  double get peakEquity => _peakEquity;
  DateTime get createdAt => _createdAt;
  List<Trade> get trades => List.unmodifiable(_trades);
  Set<String> get watchlist => _watchlist;

  Quote quote(String id) => _engine.quoteFor(id);
  double priceOf(String id) => _engine.quoteFor(id).price;

  List<Position> get openPositions =>
      _positions.values.where((p) => !p.isFlat).toList()
        ..sort((a, b) => b
            .unrealizedPnl(priceOf(b.instrumentId))
            .abs()
            .compareTo(a.unrealizedPnl(priceOf(a.instrumentId)).abs()));

  Position? positionFor(String id) {
    final p = _positions[id];
    return (p == null || p.isFlat) ? null : p;
  }

  bool isWatched(String id) => _watchlist.contains(id);

  /// Total mark-to-market account value (cash + open position values).
  double get equity {
    double v = _cash;
    for (final p in _positions.values) {
      if (p.isFlat) continue;
      v += p.marketValue(priceOf(p.instrumentId));
    }
    return v;
  }

  /// Sum of unrealized P&L across all open positions.
  double get openPnl {
    double v = 0;
    for (final p in _positions.values) {
      if (p.isFlat) continue;
      v += p.unrealizedPnl(priceOf(p.instrumentId));
    }
    return v;
  }

  /// Lifetime P&L: equity above the initial deposit.
  double get totalPnl => equity - startingCash;
  double get totalPnlPercent => totalPnl / startingCash * 100;

  /// Cash committed as cost basis across open positions.
  double get investedCapital {
    double v = 0;
    for (final p in _positions.values) {
      if (!p.isFlat) v += p.costBasis;
    }
    return v;
  }

  int get tradeCount => _trades.length;

  int get winningTrades =>
      _trades.where((t) => t.realizedPnl > _eps).length;

  int get closingTrades =>
      _trades.where((t) => t.realizedPnl.abs() > _eps).length;

  double get winRate =>
      closingTrades == 0 ? 0 : winningTrades / closingTrades * 100;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    _engine.initialize();
    await _load();
    _ready = true;
    start();
    notifyListeners();
  }

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(tickInterval, (_) => _onTick());
    _running = true;
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    notifyListeners();
  }

  void toggleRunning() {
    if (_running) {
      pause();
    } else {
      start();
      notifyListeners();
    }
  }

  void _onTick() {
    _engine.tick();
    final eq = equity;
    if (eq > _peakEquity) _peakEquity = eq;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Trading
  // ---------------------------------------------------------------------------

  /// Places a market order for [lots] of [instrumentId] on the given [side].
  ///
  /// Uses a fully-funded (no leverage) cash model: increasing exposure requires
  /// enough free cash to cover the notional, which is locked as cost basis and
  /// released (plus/minus realized P&L) when the position is reduced.
  OrderResult placeOrder(String instrumentId, OrderSide side, double lots) {
    if (!_ready) return const OrderResult(false, 'Market not ready yet.');
    if (lots <= 0) return const OrderResult(false, 'Enter a lot size greater than 0.');

    final inst = Instruments.byId(instrumentId);
    final cs = inst.contractSize;
    final price = priceOf(instrumentId);
    final d = side == OrderSide.buy ? lots : -lots;

    final existing = _positions[instrumentId];
    final l = existing?.lots ?? 0;
    var avg = existing?.avgPrice ?? 0;

    final sameDirection = l == 0 || (l > 0) == (d > 0);

    double realized = 0;
    double projectedCash = _cash;
    double newLots;
    double newAvg = avg;

    if (sameDirection) {
      final cost = lots * price * cs;
      if (cost > _cash + _eps) {
        return OrderResult(false, 'Insufficient buying power. Need ${_usd(cost)} of free cash.');
      }
      projectedCash -= cost;
      final newAbs = l.abs() + lots;
      newAvg = (l.abs() * avg + lots * price) / newAbs;
      newLots = l + d;
    } else {
      final reduceQty = min(lots, l.abs());
      final dir = l > 0 ? 1 : -1;
      realized = reduceQty * (price - avg) * cs * dir;
      projectedCash += reduceQty * avg * cs + realized;
      final extra = lots - reduceQty;
      if (extra > _eps) {
        // Position flips direction; the remainder opens a fresh position.
        final openCost = extra * price * cs;
        if (openCost > projectedCash + _eps) {
          return OrderResult(false, 'Insufficient buying power to flip. Need ${_usd(openCost)}.');
        }
        projectedCash -= openCost;
        newAvg = price;
      }
      newLots = l + d;
    }

    _cash = projectedCash;
    _realizedPnl += realized;

    if (newLots.abs() < _eps) {
      _positions.remove(instrumentId);
    } else {
      _positions[instrumentId] = Position(
        instrumentId: instrumentId,
        lots: newLots,
        avgPrice: newAvg,
        contractSize: cs,
      );
    }

    final trade = Trade(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      instrumentId: instrumentId,
      side: side,
      lots: lots,
      price: price,
      contractSize: cs,
      timestamp: DateTime.now(),
      realizedPnl: realized,
    );
    _trades.insert(0, trade);
    if (_trades.length > 300) _trades.removeRange(300, _trades.length);

    _save();
    notifyListeners();

    final pnlNote = realized.abs() > _eps
        ? ' (P&L ${_usd(realized)})'
        : '';
    return OrderResult(
      true,
      '${side.verb} ${_lots(lots)} ${inst.symbol} @ ${inst.symbol == 'NG' ? price.toStringAsFixed(3) : price.toStringAsFixed(2)}$pnlNote',
      trade,
    );
  }

  OrderResult closePosition(String instrumentId) {
    final p = _positions[instrumentId];
    if (p == null || p.isFlat) {
      return const OrderResult(false, 'No open position to close.');
    }
    final side = p.isLong ? OrderSide.sell : OrderSide.buy;
    return placeOrder(instrumentId, side, p.absLots);
  }

  // ---------------------------------------------------------------------------
  // Watchlist
  // ---------------------------------------------------------------------------
  void toggleWatch(String id) {
    if (_watchlist.contains(id)) {
      _watchlist.remove(id);
    } else {
      _watchlist.add(id);
    }
    _watchlist = {..._watchlist};
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _cash = prefs.getDouble('cash') ?? startingCash;
    _realizedPnl = prefs.getDouble('realizedPnl') ?? 0;
    _peakEquity = prefs.getDouble('peakEquity') ?? startingCash;
    _createdAt = DateTime.tryParse(prefs.getString('createdAt') ?? '') ??
        DateTime.now();

    final posJson = prefs.getString('positions');
    _positions.clear();
    if (posJson != null) {
      final List<dynamic> decoded = json.decode(posJson);
      for (final e in decoded) {
        final p = Position.fromJson(e as Map<String, dynamic>);
        if (!p.isFlat) _positions[p.instrumentId] = p;
      }
    }

    final tradesJson = prefs.getString('trades');
    _trades.clear();
    if (tradesJson != null) {
      final List<dynamic> decoded = json.decode(tradesJson);
      _trades.addAll(decoded.map((e) => Trade.fromJson(e as Map<String, dynamic>)));
    }

    final watch = prefs.getStringList('watchlist');
    if (watch != null && watch.isNotEmpty) {
      _watchlist = watch
          .where((id) => Instruments.all.any((i) => i.id == id))
          .toSet();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cash', _cash);
    await prefs.setDouble('realizedPnl', _realizedPnl);
    await prefs.setDouble('peakEquity', _peakEquity);
    await prefs.setString('createdAt', _createdAt.toIso8601String());
    await prefs.setString(
      'positions',
      json.encode(_positions.values.map((p) => p.toJson()).toList()),
    );
    await prefs.setString(
      'trades',
      json.encode(_trades.take(300).map((t) => t.toJson()).toList()),
    );
    await prefs.setStringList('watchlist', _watchlist.toList());
  }

  Future<void> resetAccount() async {
    _cash = startingCash;
    _realizedPnl = 0;
    _peakEquity = startingCash;
    _createdAt = DateTime.now();
    _positions.clear();
    _trades.clear();
    _watchlist = Instruments.all.map((i) => i.id).toSet();
    await _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _usd(double v) => '\$${v.toStringAsFixed(2)}';
  String _lots(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
