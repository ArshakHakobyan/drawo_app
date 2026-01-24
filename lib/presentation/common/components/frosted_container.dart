import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/common/components/shadow_renderer.dart';

class FrostedContainer extends StatelessWidget {
  final double borderRadius;
  const FrostedContainer({super.key, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Palette.darkSlate, Palette.deeperSlate],
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const SizedBox.expand(),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Palette.grey, width: 0.5),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ShadowRenderer(
              radius: borderRadius,
              blur: 40,
              offset: const Offset(0, 1),
              color: Palette.whiter.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
        ),
      ],
    );
  }
}
