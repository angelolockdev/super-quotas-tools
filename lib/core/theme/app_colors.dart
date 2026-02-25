/// Branded color palette for Cockpit Tools.
///
/// Each AI platform has a distinct brand color used across
/// cards, gauges, and status indicators.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────
  static const Color anthropic = Color(0xFFD97757);
  static const Color openai = Color(0xFF00A67E);
  static const Color github = Color(0xFF24292E);
  static const Color windsurf = Color(0xFFFF4F00);
  static const Color codeium = Color(0xFF09B6A2);
  static const Color cursor = Color(0xFF5755FF);

  // ── Semantic Colors ───────────────────────────────────────
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color danger = Color(0xFFE74C3C);
  static const Color info = Color(0xFF74B9FF);

  // ── Dark Theme Surface Colors ─────────────────────────────
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkNavy = Color(0xFF0F3460);

  // ── Light Theme Surface Colors ────────────────────────────
  static const Color lightSurface = Color(0xFFF8F9FD);
  static const Color lightCard = Color(0xFFFFFFFF);

  // ── Accent ────────────────────────────────────────────────
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentSecondary = Color(0xFF7F5AF0);

  /// Returns the quota usage color based on a 0.0–1.0 ratio.
  static Color quotaColor(double ratio) {
    if (ratio < 0.5) return success;
    if (ratio < 0.8) return warning;
    return danger;
  }
}
