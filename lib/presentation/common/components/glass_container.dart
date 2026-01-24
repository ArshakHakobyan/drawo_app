import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double height;
  final Widget? child;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    this.height = 102,
    this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );

    final innerShadows = [
      const BoxShadow(
        color: Color.fromRGBO(227, 227, 227, 0.2),
        blurRadius: 40,
        offset: Offset(0, 1),
        spreadRadius: 0,
      ),
      const BoxShadow(
        color: Color.fromRGBO(96, 68, 144, 0.3),
        blurRadius: 68,
        offset: Offset(0, -82),
        spreadRadius: -64,
      ),
    ];

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Stack(
        children: [
          // Background blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              width: double.infinity,
              height: height,
              color: const Color.fromRGBO(196, 196, 196, 0.01),
            ),
          ),
          // Inner Shadows
          Positioned.fill(
            child: CustomPaint(
              painter: _InnerShadowPainter(
                shadows: innerShadows,
                borderRadius: effectiveRadius,
              ),
            ),
          ),
          // Content
          SizedBox(width: double.infinity, height: height, child: child),
        ],
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;

  _InnerShadowPainter({required this.shadows, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = borderRadius.toRRect(Offset.zero & size);

    // Clip to the container shape
    canvas.clipRRect(rrect);

    for (final shadow in shadows) {
      final Paint paint = shadow.toPaint();
      final double spread = shadow.spreadRadius;

      // Inflate/deflate based on spread.
      // In CSS: positive spread expands the shadow (shrinks the inner hole).
      // RRect.deflate(v) shrinks the rect by v.
      // So deflate(spread) does what we want.
      final RRect innerRRect = rrect.deflate(spread);

      // Create a large outer rect to ensure the "solid" part covers the shadow blur area
      final Rect outerRect = (Offset.zero & size).inflate(
        shadow.blurRadius * 2 + 100,
      );

      final Path outerPath = Path()..addRect(outerRect);
      final Path innerPath = Path()..addRRect(innerRRect);

      // The shape giving the shadow is the area strictly between outer and inner
      final Path maskPath = Path.combine(
        PathOperation.difference,
        outerPath,
        innerPath,
      );

      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(maskPath, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.shadows != shadows ||
        oldDelegate.borderRadius != borderRadius;
  }
}
