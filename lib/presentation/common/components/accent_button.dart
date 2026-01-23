import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/style/text_styles.dart';
import 'package:drawo_app/core/common/app_enums.dart';
import 'package:drawo_app/presentation/common/components/app_spinner.dart';

class AccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double radius;
  final bool showLoading;
  final Color loadingColor;

  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primaryGradient,
    this.radius = 8,
    this.showLoading = false,
    this.loadingColor = Palette.whiter,
  });

  bool get _enabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final height = 48.0;
    final textStyle = AppTypography.bodyLargeMedium.copyWith(
      fontSize: 17,
      color: _textColor,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 88),
      child: SizedBox(
        width: 335,
        height: height,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _gradient,
              color: _fillColor,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: _enabled ? onPressed : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: showLoading
                          ? AppSpinner(color: loadingColor, size: 22)
                          : Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient? get _gradient {
    switch (variant) {
      case AppButtonVariant.primaryGradient:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.secondary, Palette.primary],
        );
      default:
        return null;
    }
  }

  Color? get _fillColor {
    switch (variant) {
      case AppButtonVariant.primaryGradient:
        return null; // gradient used
      case AppButtonVariant.primaryLight:
        return Colors.white;
      case AppButtonVariant.neutral:
        return const Color(0xFF6B6B6B);
      case AppButtonVariant.destructive:
        return const Color(0xFFE74D4D);
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppButtonVariant.primaryGradient:
        return Palette.whiter;
      case AppButtonVariant.primaryLight:
        return const Color(0xff131313);
      case AppButtonVariant.neutral:
        return Palette.darkGrey;
      case AppButtonVariant.destructive:
        return Palette.white;
    }
  }
}
