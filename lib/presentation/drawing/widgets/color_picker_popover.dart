import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';

class ColorPickerPopover extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final Function(Color) onColorChanged;

  const ColorPickerPopover({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    const int crossAxisCount = 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Color Picker',
            style: TextStyle(
              color: Palette.whiter,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.lightGrey,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Palette.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.0,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final color = colors[index];
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => onColorChanged(color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: -6,
              right: 24,
              child: Transform.rotate(
                angle: 45 * 3.14159 / 180,
                child: Container(
                  width: 14,
                  height: 14,
                  color: Palette.lightGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
