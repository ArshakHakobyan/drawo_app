import 'package:flutter/material.dart';

class AppTypography {
  static const display1 = TextStyle(
    fontSize: 50,
    height: 75 / 50, // lineHeight ÷ fontSize
    fontWeight: FontWeight.w800, // ExtraBold
  );
  static const display2 = TextStyle(
    fontSize: 42,
    height: 63 / 42,
    fontWeight: FontWeight.w800,
  );
  static const display3 = TextStyle(
    fontSize: 32,
    height: 42 / 32,
    fontWeight: FontWeight.w800,
  );
  static const display4 = TextStyle(
    fontSize: 32,
    height: 42 / 32,
    fontWeight: FontWeight.w600, // SemiBold
  );

  // Headings
  static const h1 = TextStyle(
    fontSize: 28,
    height: 40 / 28,
    fontWeight: FontWeight.w600,
  );
  static const h2 = TextStyle(
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w500, // Medium
  );
  static const h3 = TextStyle(
    fontSize: 24,
    height: 36 / 24,
    fontWeight: FontWeight.w600,
  );
  static const h4 = TextStyle(
    fontSize: 22,
    height: 32 / 22,
    fontWeight: FontWeight.w600,
  );
  static const h5 = TextStyle(
    fontSize: 22,
    height: 32 / 22,
    fontWeight: FontWeight.w500,
  );
  static const h6 = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );
  static const h7 = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700, // Bold
    fontStyle: FontStyle.italic,
  );
  static const h8 = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  // Body Large
  static const bodyLargeSemibold = TextStyle(
    fontSize: 18,
    height: 27 / 18,
    fontWeight: FontWeight.w600,
  );
  static const bodyLargeMedium = TextStyle(
    fontSize: 18,
    height: 27 / 18,
    fontWeight: FontWeight.w500,
  );
  static const bodyLargeRegular = TextStyle(
    fontSize: 18,
    height: 27 / 18,
    fontWeight: FontWeight.w400,
  );
  static const bodyLargeSemiboldItalic = TextStyle(
    fontSize: 18,
    height: 27 / 18,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  // Body Medium
  static const bodyMediumSemibold = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );
  static const bodyMediumMedium = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
  );
  static const bodyMediumRegular = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w400,
  );
  static const bodyMediumSemiboldItalic = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );
  static const bodyMediumMediumItalic = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  // Body Small
  static const bodySmallSemibold = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w600,
  );
  static const bodySmallMedium = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w500,
  );
  static const bodySmallRegular = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
  );
  static const bodySmallBoldItalic = TextStyle(
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );

  // Extra Small
  static const extraSmallSemibold = TextStyle(
    fontSize: 12,
    height: 14 / 12,
    fontWeight: FontWeight.w600,
  );
  static const extraSmallMedium = TextStyle(
    fontSize: 12,
    height: 24 / 12,
    fontWeight: FontWeight.w500,
  );
  static const extraSmallRegular = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );
}
