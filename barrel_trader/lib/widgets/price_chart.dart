import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A larger area/line chart with a baseline, gridlines and an optional
/// horizontal marker (e.g. an entry price). Purely painted, no dependencies.
class PriceChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double? markerPrice;
  final Color markerColor;

  const PriceChart({
    super.key,
    required this.data,
    required this.color,
    this.markerPrice,
    this.markerColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PriceChartPainter(
        data: data,
        color: color,
        markerPrice: markerPrice,
        markerColor: markerColor,
      ),
      size: Size.infinite,
    );
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double? markerPrice;
  final Color markerColor;

  _PriceChartPainter({
    required this.data,
    required this.color,
    required this.markerPrice,
    required this.markerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    double lo = data.first, hi = data.first;
    for (final v in data) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    if (markerPrice != null) {
      if (markerPrice! < lo) lo = markerPrice!;
      if (markerPrice! > hi) hi = markerPrice!;
    }
    // Add small padding so lines don't touch the edges.
    final pad = (hi - lo) * 0.08;
    lo -= pad;
    hi += pad;
    final span = (hi - lo).abs() < 1e-9 ? 1.0 : hi - lo;

    double yFor(double v) => size.height - ((v - lo) / span) * size.height;
    final dx = size.width / (data.length - 1);

    // Horizontal gridlines.
    final grid = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = dx * i;
      final y = yFor(data[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    // Latest price dot.
    final lastX = dx * (data.length - 1);
    final lastY = yFor(data.last);
    canvas.drawCircle(Offset(lastX, lastY), 3.5, Paint()..color = color);
    canvas.drawCircle(
      Offset(lastX, lastY),
      7,
      Paint()..color = color.withValues(alpha: 0.25),
    );

    // Entry / marker line (dashed).
    if (markerPrice != null) {
      final y = yFor(markerPrice!);
      final dashPaint = Paint()
        ..color = markerColor.withValues(alpha: 0.9)
        ..strokeWidth = 1.2;
      const dash = 6.0, gap = 5.0;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + dash, y), dashPaint);
        x += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter old) =>
      old.data != data ||
      old.color != color ||
      old.markerPrice != markerPrice;
}
