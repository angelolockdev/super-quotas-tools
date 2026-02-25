/// Riverpod providers for quota monitoring.
///
/// Uses Supabase Realtime streaming so the dashboard
/// updates live when desktop clients push quota changes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/quota_model.dart';
import '../../data/repositories/quota_repository.dart';

// ── Repository Provider ────────────────────────────────────
final quotaRepositoryProvider = Provider<QuotaRepository>((ref) {
  return QuotaRepository(Supabase.instance.client);
});

// ── Per-Account Quota Stream ───────────────────────────────
/// Real-time stream of quotas for a specific account ID.
final quotaStreamProvider = StreamProvider.family<List<QuotaInfo>, String>((
  ref,
  accountId,
) {
  final repo = ref.watch(quotaRepositoryProvider);
  return repo.streamQuotas(accountId);
});

// ── All Quotas (fetch-based, for dashboard overview) ───────
final allQuotasProvider = FutureProvider<List<QuotaInfo>>((ref) async {
  final repo = ref.watch(quotaRepositoryProvider);
  return repo.fetchAllQuotas();
});
