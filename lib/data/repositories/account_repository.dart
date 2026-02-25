/// Repository for CRUD operations on the Supabase `accounts` table.
///
/// All queries are automatically scoped to the current user
/// via Supabase Row-Level Security (RLS).
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../models/account_model.dart';

class AccountRepository {
  final SupabaseClient _client;

  /// Supabase table name.
  static const _table = 'accounts';

  AccountRepository(this._client);

  /// Fetch all accounts for the current user.
  Future<List<Account>> fetchAccounts() async {
    SafeLogger.info('Fetching accounts');
    final data = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((row) {
      return Account.fromJson(row as Map<String, dynamic>);
    }).toList();
  }

  /// Insert or update an account.
  Future<void> upsertAccount(Account account) async {
    SafeLogger.info('Upserting account ${account.id}');
    await _client.from(_table).upsert(account.toJson());
  }

  /// Delete an account by ID.
  Future<void> deleteAccount(String id) async {
    SafeLogger.info('Deleting account $id');
    await _client.from(_table).delete().eq('id', id);
  }

  /// Set one account as active for its platform, deactivating others.
  Future<void> setActiveAccount(Account account) async {
    SafeLogger.info(
      'Setting active account ${account.id} for ${account.platform.name}',
    );

    // Deactivate all accounts of the same platform.
    await _client
        .from(_table)
        .update({'is_active': false})
        .eq('platform', account.platform.name);

    // Activate the selected account.
    await _client
        .from(_table)
        .update({
          'is_active': true,
          'last_used_at': DateTime.now().toIso8601String(),
        })
        .eq('id', account.id);
  }
}
