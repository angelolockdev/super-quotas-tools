/// Repository for real-time quota synchronization via Supabase.
///
/// Provides a [Stream] of quota updates so the dashboard
/// displays live data pushed from desktop clients.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../models/quota_model.dart';

class QuotaRepository {
  final SupabaseClient _client;

  /// Supabase table name.
  static const _table = 'quotas';

  QuotaRepository(this._client);

  /// Fetch all quotas for a given account.
  Future<List<QuotaInfo>> fetchQuotas(String accountId) async {
    SafeLogger.info('Fetching quotas for account $accountId');
    final data = await _client
        .from(_table)
        .select()
        .eq('account_id', accountId)
        .order('label');
    return (data as List).map((row) {
      return QuotaInfo.fromJson(row as Map<String, dynamic>);
    }).toList();
  }

  /// Stream real-time quota changes for a given account.
  ///
  /// This connects to Supabase Realtime and emits a new
  /// [List<QuotaInfo>] whenever the desktop client pushes
  /// a quota update.
  Stream<List<QuotaInfo>> streamQuotas(String accountId) {
    SafeLogger.info('Streaming quotas for account $accountId');
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('account_id', accountId)
        .map((rows) {
          return rows.map((row) => QuotaInfo.fromJson(row)).toList();
        });
  }

  /// Fetch all quotas across all accounts (for dashboard overview).
  Future<List<QuotaInfo>> fetchAllQuotas() async {
    SafeLogger.info('Fetching all quotas');
    final data = await _client.from(_table).select().order('label');
    return (data as List).map((row) {
      return QuotaInfo.fromJson(row as Map<String, dynamic>);
    }).toList();
  }
}
