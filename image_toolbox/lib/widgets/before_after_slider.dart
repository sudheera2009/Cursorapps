import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// A draggable reveal comparing the original and processed image.
class BeforeAfterSlider extends StatefulWidget {
  final Uint8List before;
  final Uint8List after;
  final double height;

  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.height = 320,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _pos = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: widget.height,
            width: w,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _pos = (d.localPosition.dx / w).clamp(0.0, 1.0);
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(widget.after, fit: BoxFit.contain),
                  ClipRect(
                    clipper: _RevealClipper(_pos),
                    child: Image.memory(widget.before, fit: BoxFit.contain),
                  ),
                  Positioned(
                    left: _pos * w - 1,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: AppColors.primary),
                  ),
                  Positioned(
                    left: _pos * w - 16,
                    top: widget.height / 2 - 16,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.compare_arrows,
                          size: 18, color: Colors.black),
                    ),
                  ),
                  _tag('BEFORE', Alignment.topLeft),
                  _tag('AFTER', Alignment.topRight),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tag(String text, Alignment align) => Align(
        alignment: align,
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(text, style: AppTheme.label),
        ),
      );
}

class _RevealClipper extends CustomClipper<Rect> {
  final double pos;
  _RevealClipper(this.pos);

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, size.width * pos, size.height);

  @override
  bool shouldReclip(covariant _RevealClipper old) => old.pos != pos;
}
