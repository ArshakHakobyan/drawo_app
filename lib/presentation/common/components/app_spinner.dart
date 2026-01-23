import 'package:flutter/material.dart';

class AppSpinner extends StatelessWidget {
  final Color? color;
  final double? size;
  final String? label;

  const AppSpinner({super.key, this.color, this.size, this.label});

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 50,
          height: size ?? 50,
          child: Center(
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
              strokeWidth: 2,
            ),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
