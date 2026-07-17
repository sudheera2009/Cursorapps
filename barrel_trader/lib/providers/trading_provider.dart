import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/candle.dart';
import '../models/instrument.dart';
import '../models/market_context.dart';
import '../models/position.dart';
import '../models/quote.dart';
import '../models/signal_alert.dart';
import '../models/trade.dart';
import '../models/trade_signal.dart';
import '../services/context_provider.dart';
import '../services/indicators.dart';
import '../services/market_data_source.dart';
import '../services/notification_channel.dart';
import '../services/signal_engine.dart';

/// Outcome of attempting to place an order.
class OrderResult {
  final bool success;
  final String message;
  final Trade? trade;

  const OrderResult(this.success, this.message, [this.trade]);
}

/// Single source of truth for BARREL: the simulated market, the technical /
/// prediction / signal pipeline, the paper trading account, alerts, and
/// persistence of everything across launches.
class TradingProvider extends ChangeNotifier {
  TradingProvider({
    MarketDataSource? dataSource,
    SignalEngine? signalEngine,
    ContextProvider? contextProvider,
    this.tickInterval = const Duration(seconds: 1),
  })  : _data = dataSource ?? SimulatedMarketDataSource(),
        _signalEngine = signalEngine ?? SignalEngine(),
        _context = contextProvider ?? SimulatedContextProvider();

  final MarketDataSource _data;
  final SignalEngine _signalEngine;
  final ContextProvider _context;
  final Duration tickInterval;
  Timer? _timer;

  static const double startingCash = 100000;
  static const double _eps = 1e-6;
  static const Duration alertCooldown = Duration(seconds: 45);

  double _cash = startingCash;
  double _realizedPnl = 0;
  double _peakEquity = startingCash;
  DateTime _createdAt = DateTime.now();
  final Map<String, Position> _positions = {};
  final List<Trade> _trades = [];
  Set<String> _watchlist = Instruments.all.map((i) => i.id).toSet();
  bool _ready = false;
  bool _running = false;

  // Signal pipeline state.
  final Map<String, TradeSignal> _signals = {};
  final List<SignalAlert> _alerts = [];
  final Map<String, DateTime> _lastAlertAt = {};
  final Map<String, SignalAction> _lastAlertAction = {};
  int _tickCount = 0;

  // Alert configuration.
  bool _alertsEnabled = true;
  double _alertConfidence = 0.6;
  String _telegramToken = '';
  String _telegramChatId = '';

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
  String get dataSourceName => _data.name;
  bool get liveFeed => _data.isLive;

  Quote quote(String id) => _data.quoteFor(id);
  double priceOf(String id) => _data.priceOf(id);
  List<Candle> candlesFor(String id) => _data.candlesFor(id);
  IndicatorSnapshot indicatorsFor(String id) =>
      Indicators.snapshot(_data.candlesFor(id));
  MarketContext contextFor(String id) => _context.contextFor(id);

  TradeSignal? signalFor(String id) => _signals[id];

  /// All current signals, most actionable (highest confidence, non-WAIT) first.
  List<TradeSignal> get signals {
    final list = _signals.values.toList();
    list.sort((a, b) {
      final aw = a.action == SignalAction.wait ? 0 : 1;
      final bw = b.action == SignalAction.wait ? 0 : 1;
      if (aw != bw) return bw - aw;
      return b.confidence.compareTo(a.confidence);
    });
    return list;
  }

  List<SignalAlert> get alerts => List.unmodifiable(_alerts);
  bool get alertsEnabled => _alertsEnabled;
  double get alertConfidence => _alertConfidence;
  String get telegramToken => _telegramToken;
  String get telegramChatId => _telegramChatId;
  bool get telegramConfigured =>
      _telegramToken.isNotEmpty && _telegramChatId.isNotEmpty;

  bool isWatched(String id) => _watchlist.contains(id);

  double get equity {
    double v = _cash;
    for (final p in _positions.values) {
      if (p.isFlat) continue;
      v += p.marketValue(priceOf(p.instrumentId));
    }
    return v;
  }

  double get openPnl {
    double v = 0;
    for (final p in _positions.values) {
      if (p.isFlat) continue;
      v += p.unrealizedPnl(priceOf(p.instrumentId));
    }
    return v;
  }

  double get totalPnl => equity - startingCash;
  double get totalPnlPercent => totalPnl / startingCash * 100;

  double get investedCapital {
    double v = 0;
    for (final p in _positions.values) {
      if (!p.isFlat) v += p.costBasis;
    }
    return v;
  }

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

  int get tradeCount => _trades.length;
  int get winningTrades => _trades.where((t) => t.realizedPnl > _eps).length;
  int get closingTrades => _trades.where((t) => t.realizedPnl.abs() > _eps).length;
  double get winRate =>
      closingTrades == 0 ? 0 : winningTrades / closingTrades * 100;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    _data.initialize();
    await _load();
    _recomputeSignals();
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
    _data.tick();
    _tickCount++;
    if (_tickCount % 5 == 0) _context.tick();
    // Refresh signals every other tick to keep them responsive but cheap.
    if (_tickCount % 2 == 0) _recomputeSignals();
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
  // Signal pipeline
  // ---------------------------------------------------------------------------
  void _recomputeSignals() {
    for (final inst in Instruments.all) {
      final signal = _signalEngine.generate(
        instrumentId: inst.id,
        candles: _data.candlesFor(inst.id),
        context: _context.contextFor(inst.id),
      );
      _signals[inst.id] = signal;
      _maybeAlert(signal);
    }
  }

  void _maybeAlert(TradeSignal signal) {
    if (!_alertsEnabled) return;
    if (signal.action == SignalAction.wait) return;
    if (signal.confidence < _alertConfidence) return;

    final id = signal.instrumentId;
    final now = DateTime.now();
    final lastAction = _lastAlertAction[id];
    final lastAt = _lastAlertAt[id];
    final onCooldown =
        lastAt != null && now.difference(lastAt) < alertCooldown;
    if (lastAction == signal.action && onCooldown) return;

    final inst = Instruments.byId(id);
    final price = priceOf(id);
    final reason = signal.reasons.isNotEmpty ? signal.reasons.first.text : '';
    final message =
        '${signal.action.label} ${inst.symbol} (${inst.name})\n'
        'Price: ${price.toStringAsFixed(inst.tickSize < 0.01 ? 3 : 2)}\n'
        'Confidence: ${signal.confidencePercent}% (${signal.strength})\n'
        '$reason\n— BARREL signal';

    final alert = SignalAlert(
      id: '${now.microsecondsSinceEpoch}',
      instrumentId: id,
      action: signal.action,
      confidence: signal.confidence,
      price: price,
      message: message,
      timestamp: now,
    );
    _alerts.insert(0, alert);
    if (_alerts.length > 100) _alerts.removeRange(100, _alerts.length);
    _lastAlertAction[id] = signal.action;
    _lastAlertAt[id] = now;
    _dispatch(alert);
    _save();
  }

  void _dispatch(SignalAlert alert) {
    final channels = <NotificationChannel>[
      TelegramChannel(botToken: _telegramToken, chatId: _telegramChatId),
      const WhatsAppChannel(),
      const EmailChannel(),
    ];
    for (final c in channels) {
      if (c.enabled) {
        // Fire-and-forget; channels never throw.
        c.send(alert);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Alert configuration
  // ---------------------------------------------------------------------------
  void setAlertsEnabled(bool value) {
    _alertsEnabled = value;
    _save();
    notifyListeners();
  }

  void setAlertConfidence(double value) {
    _alertConfidence = value.clamp(0.0, 1.0);
    _save();
    notifyListeners();
  }

  void setTelegram({required String token, required String chatId}) {
    _telegramToken = token.trim();
    _telegramChatId = chatId.trim();
    _save();
    notifyListeners();
  }

  void clearAlerts() {
    _alerts.clear();
    _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Trading
  // ---------------------------------------------------------------------------
  OrderResult placeOrder(String instrumentId, OrderSide side, double lots) {
    if (!_ready) return const OrderResult(false, 'Market not ready yet.');
    if (lots <= 0) {
      return const OrderResult(false, 'Enter a lot size greater than 0.');
    }

    final inst = Instruments.byId(instrumentId);
    final cs = inst.contractSize;
    final price = priceOf(instrumentId);
    final d = side == OrderSide.buy ? lots : -lots;

    final existing = _positions[instrumentId];
    final l = existing?.lots ?? 0;
    final avg = existing?.avgPrice ?? 0;

    final sameDirection = l == 0 || (l > 0) == (d > 0);

    double realized = 0;
    double projectedCash = _cash;
    double newLots;
    double newAvg = avg;

    if (sameDirection) {
      final cost = lots * price * cs;
      if (cost > _cash + _eps) {
        return OrderResult(false,
            'Insufficient buying power. Need ${_usd(cost)} of free cash.');
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
        final openCost = extra * price * cs;
        if (openCost > projectedCash + _eps) {
          return OrderResult(
              false, 'Insufficient buying power to flip. Need ${_usd(openCost)}.');
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

    final pnlNote = realized.abs() > _eps ? ' (P&L ${_usd(realized)})' : '';
    final priceStr =
        inst.tickSize < 0.01 ? price.toStringAsFixed(3) : price.toStringAsFixed(2);
    return OrderResult(
      true,
      '${side.verb} ${_lots(lots)} ${inst.symbol} @ $priceStr$pnlNote',
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
    _createdAt =
        DateTime.tryParse(prefs.getString('createdAt') ?? '') ?? DateTime.now();

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
      _trades
          .addAll(decoded.map((e) => Trade.fromJson(e as Map<String, dynamic>)));
    }

    final alertsJson = prefs.getString('alerts');
    _alerts.clear();
    if (alertsJson != null) {
      final List<dynamic> decoded = json.decode(alertsJson);
      _alerts.addAll(
          decoded.map((e) => SignalAlert.fromJson(e as Map<String, dynamic>)));
    }

    final watch = prefs.getStringList('watchlist');
    if (watch != null && watch.isNotEmpty) {
      _watchlist =
          watch.where((id) => Instruments.all.any((i) => i.id == id)).toSet();
    }

    _alertsEnabled = prefs.getBool('alertsEnabled') ?? true;
    _alertConfidence = prefs.getDouble('alertConfidence') ?? 0.6;
    _telegramToken = prefs.getString('telegramToken') ?? '';
    _telegramChatId = prefs.getString('telegramChatId') ?? '';
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('cash', _cash);
    await prefs.setDouble('realizedPnl', _realizedPnl);
    await prefs.setDouble('peakEquity', _peakEquity);
    await prefs.setString('createdAt', _createdAt.toIso8601String());
    await prefs.setString('positions',
        json.encode(_positions.values.map((p) => p.toJson()).toList()));
    await prefs.setString(
        'trades', json.encode(_trades.take(300).map((t) => t.toJson()).toList()));
    await prefs.setString('alerts',
        json.encode(_alerts.take(100).map((a) => a.toJson()).toList()));
    await prefs.setStringList('watchlist', _watchlist.toList());
    await prefs.setBool('alertsEnabled', _alertsEnabled);
    await prefs.setDouble('alertConfidence', _alertConfidence);
    await prefs.setString('telegramToken', _telegramToken);
    await prefs.setString('telegramChatId', _telegramChatId);
  }

  Future<void> resetAccount() async {
    _cash = startingCash;
    _realizedPnl = 0;
    _peakEquity = startingCash;
    _createdAt = DateTime.now();
    _positions.clear();
    _trades.clear();
    _alerts.clear();
    _lastAlertAt.clear();
    _lastAlertAction.clear();
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
