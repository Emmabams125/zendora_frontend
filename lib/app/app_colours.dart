import 'package:flutter/material.dart';

/// Zeendora dark / lime auth theme.
/// Pulled straight from the 02-login / 03-register reference frames.
class AppColours {
  AppColours._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF1E1E1E);

  static const Color accent = Color(0xFFD7FF3D); // lime green
  static const Color accentText = Color(0xFF0A0A0A); // text on top of accent

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFF5A5A5A);

  static const Color danger = Color(0xFFFF5D5D);
}

/// Small helper for the "tech / stopwatch" look used across headers,
/// labels, and step counters. Swap fontFamily for a real mono face
/// (e.g. Space Mono / JetBrains Mono / IBM Plex Mono) once added to pubspec.
class AppTextStyles {
  AppTextStyles._();

  static const String monoFontFamily = 'monospace';

  static TextStyle label({Color color = AppColours.textSecondary}) =>
      TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 12,
        letterSpacing: 1.2,
        color: color,
        fontWeight: FontWeight.w600,
      );

  static TextStyle eyebrow({Color color = AppColours.accent}) => TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 13,
        letterSpacing: 1.5,
        color: color,
        fontWeight: FontWeight.w700,
      );

  static const TextStyle headline = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 44,
    height: 1.02,
    color: AppColours.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineAccent = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 44,
    height: 1.02,
    color: AppColours.accent,
    letterSpacing: -0.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: AppColours.textSecondary,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    color: AppColours.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 15,
    color: AppColours.textMuted,
  );
}