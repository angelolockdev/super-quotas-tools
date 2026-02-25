/// Data model for platform-specific quota information.
///
/// Different AI platforms expose quotas differently:
///   - Antigravity: per-model quotas (used/limit/resetAt)
///   - Codex:       hourly + weekly quotas
///   - Copilot:     inline suggestions + chat messages
///   - Windsurf:    user prompt credits + add-on credits
///   - Kiro:        user prompt credits + add-on credits
library;

/// The type of quota being tracked.
enum QuotaType {
  /// Generic model-level quota (Antigravity).
  model,

  /// Hourly reset window (Codex).
  hourly,

  /// Weekly reset window (Codex).
  weekly,

  /// Inline code suggestions (Copilot).
  inlineSuggestion,

  /// Chat/message completions (Copilot).
  chatMessage,

  /// User prompt credits (Windsurf, Kiro).
  promptCredit,

  /// Add-on prompt credits (Windsurf, Kiro).
  addonCredit,
}

/// A single quota metric for a given account / model.
class QuotaInfo {
  /// Unique identifier.
  final String id;

  /// The account this quota belongs to.
  final String accountId;

  /// The kind of quota.
  final QuotaType type;

  /// Human-readable label (e.g. "Claude 3.5 Sonnet", "Hourly").
  final String label;

  /// Current usage count.
  final int used;

  /// Maximum allowed within the window.
  final int limit;

  /// When this quota window resets.
  final DateTime? resetAt;

  const QuotaInfo({
    required this.id,
    required this.accountId,
    required this.type,
    required this.label,
    required this.used,
    required this.limit,
    this.resetAt,
  });

  /// Usage ratio from 0.0 to 1.0.
  double get ratio => limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

  /// Remaining count.
  int get remaining => (limit - used).clamp(0, limit);

  /// Whether the quota is fully consumed.
  bool get isExhausted => used >= limit && limit > 0;

  /// Create from Supabase row JSON.
  factory QuotaInfo.fromJson(Map<String, dynamic> json) {
    return QuotaInfo(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      type: QuotaType.values.firstWhere(
        (q) => q.name == json['type'],
        orElse: () => QuotaType.model,
      ),
      label: json['label'] as String? ?? '',
      used: json['used'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
      resetAt: json['reset_at'] != null
          ? DateTime.parse(json['reset_at'] as String)
          : null,
    );
  }

  /// Serialize to JSON for Supabase upsert.
  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'type': type.name,
    'label': label,
    'used': used,
    'limit': limit,
    'reset_at': resetAt?.toIso8601String(),
  };
}
