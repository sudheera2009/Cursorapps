import 'dart:math';

import '../models/market_context.dart';
import 'indicators.dart';

/// A named, signed contribution to the prediction.
class FeatureContribution {
  final String key;
  final double value; // signed contribution to the logit
  const FeatureContribution(this.key, this.value);
}

class Prediction {
  final double probabilityUp; // 0..1
  final List<FeatureContribution> contributions;
  const Prediction(this.probabilityUp, this.contributions);
}

/// The "AI/ML Prediction Layer".
///
/// This is a transparent logistic model that blends technical features with the
/// fundamental [MarketContext] into a probability that the next move is up. It
/// is intentionally interpretable (every contribution is exposed) and provides
/// a clean seam: a trained ML model could implement the same `predict` contract
/// by returning a probability + feature attributions.
class PredictionModel {
  const PredictionModel();

  // Feature weights (the "learned" parameters of this stand-in model).
  static const double _wEmaCross = 1.2;
  static const double _wPriceEma = 0.7;
  static const double _wMacd = 0.9;
  static const double _wRsi = 0.4;
  static const double _wBoll = 0.4; // mean-reversion
  static const double _wDi = 0.9;
  static const double _wVwap = 0.5;
  static const double _wFund = 0.8;

  Prediction predict(IndicatorSnapshot ind, MarketContext ctx) {
    final close = ind.lastClose == 0 ? 1.0 : ind.lastClose;
    final atr = ind.atr14 == 0 ? close * 0.01 : ind.atr14;

    // ADX gates the pure trend-following features (weak when ADX is low).
    final adxGate = (ind.adx14 / 40).clamp(0.0, 1.0);
    final trendGate = 0.4 + 0.6 * adxGate;

    final fEmaCross =
        _tanh(((ind.ema9 - ind.ema21) / (ind.ema21 == 0 ? 1 : ind.ema21)) * 100);
    final fPriceEma =
        _tanh(((close - ind.ema50) / (ind.ema50 == 0 ? 1 : ind.ema50)) * 60);
    final fMacd = _tanh((ind.macdHist / atr) * 1.5);
    final fRsi = _tanh((ind.rsi14 - 50) / 20);
    final fBoll = _tanh((0.5 - ind.bbPercentB) * 2); // near upper band => bearish
    final diSum = ind.plusDI + ind.minusDI;
    final fDi = diSum == 0 ? 0.0 : (ind.plusDI - ind.minusDI) / diSum;
    final fVwap = _tanh(((close - ind.vwap) / (ind.vwap == 0 ? 1 : ind.vwap)) * 80);
    final fFund = ctx.fundamentalScore;

    final contributions = <FeatureContribution>[
      FeatureContribution('ema_cross', _wEmaCross * fEmaCross * trendGate),
      FeatureContribution('price_ema50', _wPriceEma * fPriceEma),
      FeatureContribution('macd', _wMacd * fMacd),
      FeatureContribution('rsi', _wRsi * fRsi),
      FeatureContribution('bollinger', _wBoll * fBoll),
      FeatureContribution('adx_di', _wDi * fDi * trendGate),
      FeatureContribution('vwap', _wVwap * fVwap),
      FeatureContribution('fundamental', _wFund * fFund),
    ];

    double z = 0;
    for (final c in contributions) {
      z += c.value;
    }

    return Prediction(_sigmoid(z), contributions);
  }

  static double _sigmoid(double x) => 1 / (1 + exp(-x));

  static double _tanh(double x) {
    if (x > 20) return 1;
    if (x < -20) return -1;
    final e2 = exp(2 * x);
    return (e2 - 1) / (e2 + 1);
  }
}
