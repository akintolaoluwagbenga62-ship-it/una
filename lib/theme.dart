import 'package:flutter/material.dart';

// ── COLORS ────────────────────────────────────────────────────────────────────
class BColor {
  // Dark palette
  static const bg     = Color(0xFF000000);
  static const bg1    = Color(0xFF111111);
  static const bg2    = Color(0xFF1A1A1A);
  static const border = Color(0xFF2A2A2A);
  static const muted  = Color(0xFF666666);
  static const text   = Color(0xFFFFFFFF);
  static const textSub= Color(0xFFBBBBBB);

  // Accent — green only
  static const green  = Color(0xFF00C47A);
  static const greenDim = Color(0xFF007A4D);

  // Semantic
  static const danger = Color(0xFFE53935);
  static const gold   = Color(0xFFFFB300);
  static const chill  = Color(0xFF00C47A);  // map chill → green
  static const hype   = Color(0xFFFFFFFF);  // map hype → white
  static const deep   = Color(0xFF00C47A);  // map deep → green
  static const funny  = Color(0xFFFFB300);  // map funny → gold

  // Logo — white + green instead of purple/cyan
  static const logoA  = Color(0xFF00C47A);
  static const logoB  = Color(0xFFFFFFFF);

  static Color mood(String m) {
    switch (m) {
      case 'hype':  return hype;
      case 'chill': return chill;
      case 'deep':  return deep;
      case 'funny': return funny;
      default:      return muted;
    }
  }

  // Safe opacity helpers (no deprecated withOpacity)
  static Color alpha(Color c, int a) => c.withAlpha(a); // 0–255
}

// ── THEME ─────────────────────────────────────────────────────────────────────
ThemeData bondlyTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: BColor.bg,
  colorScheme: const ColorScheme.dark(
    surface: BColor.bg,
    onSurface: BColor.text,
    primary: BColor.green,
    secondary: BColor.green,
    error: BColor.danger,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: BColor.bg,
    foregroundColor: BColor.text,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: BColor.text, fontSize: 16, fontWeight: FontWeight.w700),
  ),
  textTheme: const TextTheme(
    bodyLarge:  TextStyle(color: BColor.text,    fontSize: 15),
    bodyMedium: TextStyle(color: BColor.textSub, fontSize: 14),
    bodySmall:  TextStyle(color: BColor.muted,   fontSize: 12),
    labelLarge: TextStyle(color: BColor.text,    fontWeight: FontWeight.w700),
  ),
  dividerTheme: const DividerThemeData(color: BColor.border, thickness: 0.5),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: BColor.bg2,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BColor.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BColor.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: BColor.green),
    ),
    hintStyle: const TextStyle(color: BColor.muted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: BColor.bg,
    selectedItemColor: BColor.green,
    unselectedItemColor: BColor.muted,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  cardColor: BColor.bg1,
  dialogBackgroundColor: BColor.bg1,
);
