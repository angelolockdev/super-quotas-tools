/// Data model for per-platform configuration.
///
/// Stores platform-level settings like custom paths,
/// auto-refresh intervals, and feature flags.
library;

import '../../core/constants/platform_constants.dart';

class PlatformConfig {
  /// Which platform this config applies to.
  final AiPlatform platform;

  /// Whether auto-refresh is enabled for this platform.
  final bool autoRefresh;

  /// Auto-refresh interval in minutes.
  final int refreshIntervalMinutes;

  /// Whether wake-up tasks are enabled (Antigravity only).
  final bool wakeUpEnabled;

  /// Custom user data directory path (desktop sync reference).
  final String? customDataPath;

  const PlatformConfig({
    required this.platform,
    this.autoRefresh = true,
    this.refreshIntervalMinutes = 5,
    this.wakeUpEnabled = false,
    this.customDataPath,
  });

  /// Create from Supabase row JSON.
  factory PlatformConfig.fromJson(Map<String, dynamic> json) {
    return PlatformConfig(
      platform: AiPlatform.values.firstWhere(
        (p) => p.name == json['platform'],
        orElse: () => AiPlatform.antigravity,
      ),
      autoRefresh: json['auto_refresh'] as bool? ?? true,
      refreshIntervalMinutes: json['refresh_interval_minutes'] as int? ?? 5,
      wakeUpEnabled: json['wake_up_enabled'] as bool? ?? false,
      customDataPath: json['custom_data_path'] as String?,
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => {
    'platform': platform.name,
    'auto_refresh': autoRefresh,
    'refresh_interval_minutes': refreshIntervalMinutes,
    'wake_up_enabled': wakeUpEnabled,
    'custom_data_path': customDataPath,
  };
}
