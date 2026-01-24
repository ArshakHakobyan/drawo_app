import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/presentation/common/components/glass_container.dart';

class CommonHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final double sideWidth;

  const CommonHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.height = 102,
    this.sideWidth = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GlassContainer(
        height: height,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Leading icon
                SizedBox(
                  width: sideWidth,
                  child: leading != null
                      ? Align(alignment: Alignment.centerLeft, child: leading)
                      : const SizedBox.shrink(),
                ),
                //Title of the header
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Palette.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Actions side
                SizedBox(
                  width: sideWidth, // Fixed width for alignment
                  child: actions != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
