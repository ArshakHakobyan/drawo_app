import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassContainer extends StatelessWidget {
  final double height;
  final Widget? child;
  final BorderRadius? borderRadius;

  const FrostedGlassContainer({
    super.key,
    this.height = 102,
    this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Exact specs from screenshot: Gap 14px, Height 102px, Radius Bottom-right 8px, Bottom-left 8px,
    // Color rgba(196,196,196,0.01), Blur 100, Inner shadow Blur 40, Y 1, rgba(227,227,227,0.2)

    final effectiveRadius =
        borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );

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
              color: const Color(0xFFC4C4C4).withOpacity(0.01),
            ),
          ),

          // Inner shadow / Border overlay
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              // Inner shadow simulation
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE3E3E3).withOpacity(0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
