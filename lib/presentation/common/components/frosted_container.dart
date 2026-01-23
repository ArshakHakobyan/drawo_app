import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drawo_app/presentation/common/components/shadow_renderer.dart';

class FrostedContainer extends StatelessWidget {
  final double borderRadius;
  const FrostedContainer({super.key, this.borderRadius = 8});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF87858F);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C3E50), Color(0xFF16212C)],
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
            border: Border.all(color: borderColor, width: 0.5),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ShadowRenderer(
              radius: borderRadius,
              blur: 40,
              offset: const Offset(0, 1),
              color: const Color(0xffE3E3E3).withOpacity(0.2),
              thickness: 1,
            ),
          ),
        ),
      ],
    );
  }
}
