import 'package:flutter/material.dart';

class ShadowRenderer extends CustomPainter {
  final double radius;
  final double blur;
  final Offset offset;
  final Color color;
  final double thickness;

  ShadowRenderer({
    required this.radius,
    required this.blur,
    required this.offset,
    required this.color,
    this.thickness = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final outer = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final innerRect = rect.deflate(thickness);
    final inner = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular((radius - thickness).clamp(0, radius)),
    );

    final ring = Path()
      ..addRRect(outer)
      ..addRRect(inner)
      ..fillType = PathFillType.evenOdd;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawPath(ring, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ShadowRenderer old) =>
      old.radius != radius ||
      old.blur != blur ||
      old.offset != offset ||
      old.color != color ||
      old.thickness != thickness;
}
