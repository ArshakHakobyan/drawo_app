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
              image: AssetImage(MediaAssets.backgroundimage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xff131313).withOpacity(0.75),
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
