import 'package:flutter/material.dart';
import 'package:drawo_app/core/resources/media_assets.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(MediaAssets.backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xff131313).withValues(alpha: 0.75),
        ),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(MediaAssets.pattern),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
