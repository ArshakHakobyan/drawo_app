import 'package:flutter/material.dart';
import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/style/palette.dart';

class MainBackground extends StatelessWidget {
  const MainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Image Layer
        Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(MediaAssets.backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Dark Overlay for contrast
        Container(
          constraints: const BoxConstraints.expand(),
          color: Palette.black.withValues(alpha: 0.75),
        ),
        // Pattern Overlay
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(MediaAssets.pattern),
              fit: BoxFit.cover,
              opacity: 0.5, // Slight transparency for pattern
            ),
          ),
        ),
      ],
    );
  }
}
