import 'package:flutter/material.dart';
import 'package:drawo_app/core/resources/media_assets.dart';
import 'package:drawo_app/core/style/palette.dart';

class ToolbarAction extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final VoidCallback onTap;
  final bool isActive;
  final Color? color;

  const ToolbarAction({
    super.key,
    this.icon,
    this.iconData,
    required this.onTap,
    this.isActive = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? Palette.primary.withValues(alpha: 0.3)
              : Palette.darkGrey.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconData != null
              ? Icon(iconData, color: color ?? Palette.white, size: 24)
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      icon!,
                      height: 24,
                      color: (color != null && icon != MediaAssets.pickerIcon)
                          ? color
                          : Palette.white,
                    ),
                    if (icon == MediaAssets.pickerIcon && color != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Palette.white, width: 1),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
