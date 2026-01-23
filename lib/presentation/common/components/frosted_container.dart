import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drawo_app/presentation/common/components/shadow_renderer.dart';

class FrostedContainer extends StatelessWidget {
  const FrostedContainer({super.key});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFF87858F);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF2C3E50), Color(0xFF16212C)],
            ),
          ),
        ),

        SizedBox(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const SizedBox.expand(),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 0.5),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: ShadowRenderer(
              radius: 20,
              blur: 40,
              offset: const Offset(0, 0),
              color: const Color(0xffE3E3E3).withOpacity(0.2),
              thickness: 1,
            ),
          ),
        ),
      ],
    );
  }
}
