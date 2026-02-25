/// Platform constants — enum, icons, brand colors, and labels
/// for each supported AI IDE platform.
library;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The AI IDE platforms managed by Cockpit Tools.
enum AiPlatform { anthropic, openai, github, windsurf, codeium, cursor }

/// Extension providing display metadata for each platform.
extension AiPlatformX on AiPlatform {
  /// Human-readable label.
  String get label => switch (this) {
    AiPlatform.anthropic => 'Anthropic',
    AiPlatform.openai => 'OpenAI',
    AiPlatform.github => 'GitHub',
    AiPlatform.windsurf => 'Windsurf',
    AiPlatform.codeium => 'Codeium',
    AiPlatform.cursor => 'Cursor',
  };

  /// Brand color used in cards and gauges.
  Color get brandColor => switch (this) {
    AiPlatform.anthropic => AppColors.anthropic,
    AiPlatform.openai => AppColors.openai,
    AiPlatform.github => AppColors.github,
    AiPlatform.windsurf => AppColors.windsurf,
    AiPlatform.codeium => AppColors.codeium,
    AiPlatform.cursor => AppColors.cursor,
  };

  /// SVG asset path for the platform logo.
  String get svgPath => 'assets/icons/$name.svg';

  /// Icon used in platform cards as fallback.
  IconData get icon => switch (this) {
    AiPlatform.anthropic => Icons.bubble_chart_rounded,
    AiPlatform.openai => Icons.bolt_rounded,
    AiPlatform.github => Icons.code_rounded,
    AiPlatform.windsurf => Icons.air_rounded,
    AiPlatform.codeium => Icons.auto_awesome_rounded,
    AiPlatform.cursor => Icons.ads_click_rounded,
  };

  /// Short description shown in dashboard tooltips.
  String get subtitle => switch (this) {
    AiPlatform.anthropic => 'Claude 3.5 · Multi-account',
    AiPlatform.openai => 'GPT-4o · API & Playground',
    AiPlatform.github => 'Copilot · Enterprise & Individual',
    AiPlatform.windsurf => 'Flow · Prompt credits',
    AiPlatform.codeium => 'Pro · Individual · Enterprise',
    AiPlatform.cursor => 'Composer · Pro · Hobby',
  };
}
