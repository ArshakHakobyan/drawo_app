import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';

class HeaderIconButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const HeaderIconButton({
    super.key,
    this.asset,
    this.icon,
    required this.color,
    required this.onTap,
  }) : assert(asset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        overlayColor: WidgetStatePropertyAll(
          Palette.white.withValues(alpha: 0.15),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: icon != null
              ? Icon(icon, size: 24, color: color)
              : Image.asset(asset!, width: 24, height: 24, color: color),
        ),
      ),
    );
  }
}
