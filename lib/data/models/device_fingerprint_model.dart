/// Data model for device fingerprints.
///
/// Fingerprints help reduce risk-control flags when switching
/// accounts on the Antigravity platform.
library;

class DeviceFingerprint {
  /// Unique fingerprint identifier (UUID).
  final String id;

  /// The computed fingerprint hash.
  final String hash;

  /// User-defined label (e.g., "MacBook Work", "Windows Home").
  final String label;

  /// The account ID this fingerprint is currently bound to.
  final String? boundAccountId;

  /// When the fingerprint was created.
  final DateTime createdAt;

  const DeviceFingerprint({
    required this.id,
    required this.hash,
    this.label = '',
    this.boundAccountId,
    required this.createdAt,
  });

  /// Create from Supabase row JSON.
  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) {
    return DeviceFingerprint(
      id: json['id'] as String,
      hash: json['hash'] as String? ?? '',
      label: json['label'] as String? ?? '',
      boundAccountId: json['bound_account_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'hash': hash,
    'label': label,
    'bound_account_id': boundAccountId,
    'created_at': createdAt.toIso8601String(),
  };
}
