import '../models/candle.dart';
import '../models/market_context.dart';
import '../models/trade_signal.dart';
import 'indicators.dart';
import 'prediction_model.dart';

/// The "Signal Generation Engine".
///
/// Turns the prediction-layer output into an actionable BUY / SELL / WAIT call
/// with a confidence score and the top human-readable reasons behind it.
class SignalEngine {
  SignalEngine({
    PredictionModel? model,
    this.buyThreshold = 0.58,
    this.sellThreshold = 0.42,
  }) : _model = model ?? const PredictionModel();

  final PredictionModel _model;
  final double buyThreshold;
  final double sellThreshold;

  /// Generates a signal from raw candles + fundamental context.
  TradeSignal generate({
    required String instrumentId,
    required List<Candle> candles,
    MarketContext context = MarketContext.neutral,
  }) {
    final ind = Indicators.snapshot(candles);
    return generateFromSnapshot(
      instrumentId: instrumentId,
      indicators: ind,
      context: context,
    );
  }

  TradeSignal generateFromSnapshot({
    required String instrumentId,
    required IndicatorSnapshot indicators,
    MarketContext context = MarketContext.neutral,
  }) {
    final prediction = _model.predict(indicators, context);
    final p = prediction.probabilityUp;

    final SignalAction action;
    if (p >= buyThreshold) {
      action = SignalAction.buy;
    } else if (p <= sellThreshold) {
      action = SignalAction.sell;
    } else {
      action = SignalAction.wait;
    }

    final confidence = ((p - 0.5).abs() * 2).clamp(0.0, 1.0);

    return TradeSignal(
      instrumentId: instrumentId,
      action: action,
      probabilityUp: p,
      confidence: confidence,
      reasons: _reasons(prediction, indicators, context),
      timestamp: DateTime.now(),
    );
  }

  List<SignalReason> _reasons(
    Prediction prediction,
    IndicatorSnapshot ind,
    MarketContext ctx,
  ) {
    final sorted = [...prediction.contributions]
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    final reasons = <SignalReason>[];
    for (final c in sorted) {
      if (c.value.abs() < 0.05) continue;
      final bullish = c.value > 0;
      final text = _describe(c.key, bullish, ind, ctx);
      if (text != null) reasons.add(SignalReason(text, bullish, c.value.abs()));
      if (reasons.length >= 4) break;
    }
    if (reasons.isEmpty) {
      reasons.add(const SignalReason('No dominant edge — mixed signals', false, 0));
    }
    return reasons;
  }

  String? _describe(
    String key,
    bool bullish,
    IndicatorSnapshot ind,
    MarketContext ctx,
  ) {
    switch (key) {
      case 'ema_cross':
        return bullish
            ? 'EMA-9 above EMA-21 (uptrend)'
            : 'EMA-9 below EMA-21 (downtrend)';
      case 'price_ema50':
        return bullish
            ? 'Price holding above the 50-EMA'
            : 'Price below the 50-EMA';
      case 'macd':
        return bullish
            ? 'MACD histogram positive & rising'
            : 'MACD histogram negative';
      case 'rsi':
        if (ind.rsi14 >= 70) return 'RSI overbought (${ind.rsi14.toStringAsFixed(0)})';
        if (ind.rsi14 <= 30) return 'RSI oversold (${ind.rsi14.toStringAsFixed(0)})';
        return bullish
            ? 'RSI momentum positive (${ind.rsi14.toStringAsFixed(0)})'
            : 'RSI momentum negative (${ind.rsi14.toStringAsFixed(0)})';
      case 'bollinger':
        return bullish
            ? 'Near lower Bollinger band (stretched down)'
            : 'Near upper Bollinger band (stretched up)';
      case 'adx_di':
        return bullish
            ? '+DI over -DI, ADX ${ind.adx14.toStringAsFixed(0)} (bulls control)'
            : '-DI over +DI, ADX ${ind.adx14.toStringAsFixed(0)} (bears control)';
      case 'vwap':
        return bullish ? 'Trading above session VWAP' : 'Trading below session VWAP';
      case 'fundamental':
        final parts = <String>[];
        if (ctx.newsSentiment.abs() > 0.2) {
          parts.add('news ${ctx.newsSentiment > 0 ? 'bullish' : 'bearish'}');
        }
        if (ctx.inventorySurprise.abs() > 0.2) {
          parts.add('EIA ${ctx.inventorySurprise > 0 ? 'draw' : 'build'}');
        }
        if (ctx.weatherFactor.abs() > 0.2) {
          parts.add('weather ${ctx.weatherFactor > 0 ? 'supportive' : 'soft'}');
        }
        if (parts.isEmpty) {
          return bullish ? 'Fundamentals lean bullish' : 'Fundamentals lean bearish';
        }
        return 'Fundamentals: ${parts.join(', ')}';
      default:
        return null;
    }
  }
}
