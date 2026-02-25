/// Data model for an AI IDE account.
///
/// Maps to the Supabase `accounts` table.
/// Token fields are stored ONLY in [SecureStorageService]
/// and are never serialized to the network or logs.
library;

import '../../core/constants/platform_constants.dart';

/// Subscription plan tier names across platforms.
enum PlanType {
  free,
  basic,
  plus,
  pro,
  individual,
  team,
  business,
  enterprise,
  unknown,
}

/// A single managed account on one AI IDE platform.
class Account {
  /// Unique identifier (UUID).
  final String id;

  /// Which AI IDE this account belongs to.
  final AiPlatform platform;

  /// Account email address.
  final String email;

  /// Human-readable display name.
  final String displayName;

  /// Subscription plan type.
  final PlanType plan;

  /// User-defined tags for grouping (e.g., "work", "personal").
  final List<String> tags;

  /// Whether this is the currently active account for its platform.
  final bool isActive;

  /// When the account was added.
  final DateTime createdAt;

  /// When the account was last switched to.
  final DateTime? lastUsedAt;

  const Account({
    required this.id,
    required this.platform,
    required this.email,
    this.displayName = '',
    this.plan = PlanType.unknown,
    this.tags = const [],
    this.isActive = false,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Create from Supabase row JSON.
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      platform: AiPlatform.values.firstWhere(
        (p) => p.name == json['platform'],
        orElse: () => AiPlatform.anthropic,
      ),
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      plan: PlanType.values.firstWhere(
        (p) => p.name == json['plan'],
        orElse: () => PlanType.unknown,
      ),
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [],
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.parse(json['last_used_at'] as String)
          : null,
    );
  }

  /// Serialize to JSON for Supabase upsert.
  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform.name,
    'email': email,
    'display_name': displayName,
    'plan': plan.name,
    'tags': tags,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'last_used_at': lastUsedAt?.toIso8601String(),
  };

  /// Returns a copy with selected fields overridden.
  Account copyWith({
    bool? isActive,
    PlanType? plan,
    List<String>? tags,
    DateTime? lastUsedAt,
  }) {
    return Account(
      id: id,
      platform: platform,
      email: email,
      displayName: displayName,
      plan: plan ?? this.plan,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}
