import 'dart:math';

import '../models/candle.dart';

/// The latest values of every technical indicator BARREL tracks.
class IndicatorSnapshot {
  final double lastClose;
  final double ema9;
  final double ema21;
  final double ema50;
  final double rsi14;
  final double macd;
  final double macdSignal;
  final double macdHist;
  final double atr14;
  final double bbUpper;
  final double bbMid;
  final double bbLower;
  final double bbPercentB; // 0 = lower band, 1 = upper band
  final double bbWidth; // (upper-lower)/mid
  final double adx14;
  final double plusDI;
  final double minusDI;
  final double vwap;

  const IndicatorSnapshot({
    required this.lastClose,
    required this.ema9,
    required this.ema21,
    required this.ema50,
    required this.rsi14,
    required this.macd,
    required this.macdSignal,
    required this.macdHist,
    required this.atr14,
    required this.bbUpper,
    required this.bbMid,
    required this.bbLower,
    required this.bbPercentB,
    required this.bbWidth,
    required this.adx14,
    required this.plusDI,
    required this.minusDI,
    required this.vwap,
  });
}

/// The "Technical Indicator Engine" node of the pipeline.
///
/// Pure functions over OHLC candles. Implementations follow the standard
/// definitions (Wilder smoothing for RSI/ATR/ADX, exponential smoothing for
/// EMA/MACD, session VWAP from typical price × volume).
class Indicators {
  /// Exponential moving average, seeded from the first value. Returns a series
  /// the same length as [src].
  static List<double> ema(List<double> src, int period) {
    final out = <double>[];
    if (src.isEmpty) return out;
    final k = 2 / (period + 1);
    double prev = src.first;
    out.add(prev);
    for (int i = 1; i < src.length; i++) {
      prev = src[i] * k + prev * (1 - k);
      out.add(prev);
    }
    return out;
  }

  /// Simple moving average over the last [period] values.
  static double sma(List<double> src, int period) {
    if (src.isEmpty) return 0;
    final n = min(period, src.length);
    double sum = 0;
    for (int i = src.length - n; i < src.length; i++) {
      sum += src[i];
    }
    return sum / n;
  }

  /// Wilder's RSI over [period] closes. Ranges 0..100.
  static double rsi(List<double> closes, {int period = 14}) {
    if (closes.length < period + 1) return 50;
    double gain = 0, loss = 0;
    for (int i = 1; i <= period; i++) {
      final ch = closes[i] - closes[i - 1];
      if (ch >= 0) {
        gain += ch;
      } else {
        loss -= ch;
      }
    }
    gain /= period;
    loss /= period;
    for (int i = period + 1; i < closes.length; i++) {
      final ch = closes[i] - closes[i - 1];
      final g = ch > 0 ? ch : 0;
      final l = ch < 0 ? -ch : 0;
      gain = (gain * (period - 1) + g) / period;
      loss = (loss * (period - 1) + l) / period;
    }
    if (loss == 0) return 100;
    final rs = gain / loss;
    return 100 - 100 / (1 + rs);
  }

  /// MACD (fast, slow, signal). Returns (macd, signal, histogram) latest values.
  static (double, double, double) macd(
    List<double> closes, {
    int fast = 12,
    int slow = 26,
    int signalPeriod = 9,
  }) {
    if (closes.length < slow) {
      return (0, 0, 0);
    }
    final emaFast = ema(closes, fast);
    final emaSlow = ema(closes, slow);
    final macdLine = <double>[
      for (int i = 0; i < closes.length; i++) emaFast[i] - emaSlow[i],
    ];
    final signalLine = ema(macdLine, signalPeriod);
    final macdVal = macdLine.last;
    final signalVal = signalLine.last;
    return (macdVal, signalVal, macdVal - signalVal);
  }

  /// Wilder's Average True Range.
  static double atr(List<Candle> candles, {int period = 14}) {
    if (candles.length < period + 1) return 0;
    final trs = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final h = candles[i].high;
      final l = candles[i].low;
      final pc = candles[i - 1].close;
      trs.add([h - l, (h - pc).abs(), (l - pc).abs()].reduce(max));
    }
    double atr = 0;
    for (int i = 0; i < period; i++) {
      atr += trs[i];
    }
    atr /= period;
    for (int i = period; i < trs.length; i++) {
      atr = (atr * (period - 1) + trs[i]) / period;
    }
    return atr;
  }

  /// Bollinger Bands: (upper, mid, lower, %b, bandwidth).
  static (double, double, double, double, double) bollinger(
    List<double> closes, {
    int period = 20,
    double mult = 2,
  }) {
    if (closes.isEmpty) return (0, 0, 0, 0.5, 0);
    final n = min(period, closes.length);
    final window = closes.sublist(closes.length - n);
    final mid = window.reduce((a, b) => a + b) / n;
    double variance = 0;
    for (final v in window) {
      variance += (v - mid) * (v - mid);
    }
    final sd = sqrt(variance / n);
    final upper = mid + mult * sd;
    final lower = mid - mult * sd;
    final last = closes.last;
    final span = upper - lower;
    final percentB = span == 0 ? 0.5 : (last - lower) / span;
    final width = mid == 0 ? 0 : span / mid;
    return (upper, mid, lower, percentB.toDouble(), width.toDouble());
  }

  /// Wilder's ADX with directional indicators: (adx, +DI, -DI).
  static (double, double, double) adx(List<Candle> candles, {int period = 14}) {
    if (candles.length < period * 2) return (0, 0, 0);
    final trs = <double>[];
    final plusDM = <double>[];
    final minusDM = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final h = candles[i].high, l = candles[i].low;
      final ph = candles[i - 1].high, pl = candles[i - 1].low;
      final pc = candles[i - 1].close;
      final up = h - ph;
      final down = pl - l;
      plusDM.add((up > down && up > 0) ? up : 0);
      minusDM.add((down > up && down > 0) ? down : 0);
      trs.add([h - l, (h - pc).abs(), (l - pc).abs()].reduce(max));
    }

    double smooth(List<double> src, int start) {
      double s = 0;
      for (int i = start; i < start + period; i++) {
        s += src[i];
      }
      return s;
    }

    double trS = smooth(trs, 0);
    double plusS = smooth(plusDM, 0);
    double minusS = smooth(minusDM, 0);

    final dxs = <double>[];
    for (int i = period; i < trs.length; i++) {
      trS = trS - trS / period + trs[i];
      plusS = plusS - plusS / period + plusDM[i];
      minusS = minusS - minusS / period + minusDM[i];
      final plusDI = trS == 0 ? 0 : 100 * plusS / trS;
      final minusDI = trS == 0 ? 0 : 100 * minusS / trS;
      final diSum = plusDI + minusDI;
      final dx = diSum == 0 ? 0 : 100 * (plusDI - minusDI).abs() / diSum;
      dxs.add(dx.toDouble());
    }
    if (dxs.isEmpty) return (0, 0, 0);

    double adx = 0;
    final firstN = min(period, dxs.length);
    for (int i = 0; i < firstN; i++) {
      adx += dxs[i];
    }
    adx /= firstN;
    for (int i = firstN; i < dxs.length; i++) {
      adx = (adx * (period - 1) + dxs[i]) / period;
    }

    final plusDI = trS == 0 ? 0.0 : 100 * plusS / trS;
    final minusDI = trS == 0 ? 0.0 : 100 * minusS / trS;
    return (adx, plusDI.toDouble(), minusDI.toDouble());
  }

  /// Session VWAP from typical price × volume.
  static double vwap(List<Candle> candles) {
    if (candles.isEmpty) return 0;
    double pv = 0, vol = 0;
    for (final c in candles) {
      pv += c.typical * c.volume;
      vol += c.volume;
    }
    return vol == 0 ? candles.last.close : pv / vol;
  }

  /// Computes every indicator for the given candles.
  static IndicatorSnapshot snapshot(List<Candle> candles) {
    final closes = candles.map((c) => c.close).toList();
    final last = closes.isEmpty ? 0.0 : closes.last;
    final (macdVal, macdSignal, macdHist) = macd(closes);
    final (bbU, bbM, bbL, bbPB, bbW) = bollinger(closes);
    final (adxVal, plusDI, minusDI) = adx(candles);
    return IndicatorSnapshot(
      lastClose: last,
      ema9: closes.isEmpty ? 0 : ema(closes, 9).last,
      ema21: closes.isEmpty ? 0 : ema(closes, 21).last,
      ema50: closes.isEmpty ? 0 : ema(closes, 50).last,
      rsi14: rsi(closes),
      macd: macdVal,
      macdSignal: macdSignal,
      macdHist: macdHist,
      atr14: atr(candles),
      bbUpper: bbU,
      bbMid: bbM,
      bbLower: bbL,
      bbPercentB: bbPB,
      bbWidth: bbW,
      adx14: adxVal,
      plusDI: plusDI,
      minusDI: minusDI,
      vwap: vwap(candles),
    );
  }
}
