import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';

class PropertyHeader extends StatelessWidget {
  final String title;
  final Widget? icon;
  final bool isChecked;
  final ValueChanged<bool>? onToggle;

  const PropertyHeader({
    super.key,
    required this.title,
    this.icon,
    this.isChecked = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Custom Checkbox
          GestureDetector(
            onTap: () => onToggle?.call(!isChecked),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isChecked ? Palette.primary : Colors.transparent,
                border: Border.all(
                  color: isChecked
                      ? Palette.primary
                      : Palette.whiter.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 12, color: Palette.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Section Icon
          if (icon != null) ...[icon!, const SizedBox(width: 12)],

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Palette.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
