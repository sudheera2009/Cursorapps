import 'package:flutter/material.dart';

/// A tiny inline line chart with no axes, used inside market rows.
class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(data, color, strokeWidth),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _SparklinePainter(this.data, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    double lo = data.first, hi = data.first;
    for (final v in data) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    final span = (hi - lo).abs() < 1e-9 ? 1.0 : hi - lo;
    final dx = size.width / (data.length - 1);

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = dx * i;
      final y = size.height - ((data[i] - lo) / span) * size.height;
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
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.color != color;
}
