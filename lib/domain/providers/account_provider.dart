/// Riverpod providers for account management.
///
/// Fetches, caches, and provides account data from Supabase.
/// Supports one-click account switching.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/platform_constants.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';
import 'storage_provider.dart';

// ── Repository Provider ────────────────────────────────────
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(Supabase.instance.client);
});

// ── All Accounts Provider ──────────────────────────────────
/// Async provider that fetches all accounts from Supabase.
final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    return repo.fetchAccounts();
  }

  /// Force-refresh accounts from Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(accountRepositoryProvider);
      return repo.fetchAccounts();
    });
  }

  /// Switch the active account for a given platform.
  Future<void> switchAccount(Account account) async {
    final repo = ref.read(accountRepositoryProvider);
    await repo.setActiveAccount(account);
    await refresh();
  }

  /// Add a new account and securely store its tokens.
  Future<void> addAccount({
    required Account account,
    required Map<String, String> tokens,
  }) async {
    final repo = ref.read(accountRepositoryProvider);
    final storage = ref.read(secureStorageServiceProvider);

    // 1. Save tokens to secure storage.
    for (final entry in tokens.entries) {
      await storage.saveToken(
        accountId: account.id,
        key: entry.key,
        value: entry.value,
      );
    }

    // 2. Refresh Supabase account metadata.
    await repo.upsertAccount(account);

    // 3. Mark as active (which deactivates others).
    await repo.setActiveAccount(account);

    await refresh();
  }

  /// Delete an account and its associated secure tokens.
  Future<void> deleteAccount(String id) async {
    final repo = ref.read(accountRepositoryProvider);
    final storage = ref.read(secureStorageServiceProvider);

    // 1. Remove from cloud.
    await repo.deleteAccount(id);

    // 2. Purge local tokens.
    await storage.deleteAllForAccount(id);

    await refresh();
  }
}

// ── Per-Platform Filtered Providers ────────────────────────
/// Provides accounts filtered by a specific platform.
final platformAccountsProvider =
    Provider.family<AsyncValue<List<Account>>, AiPlatform>((ref, platform) {
      final allAccounts = ref.watch(accountsProvider);
      return allAccounts.whenData(
        (accounts) => accounts.where((a) => a.platform == platform).toList(),
      );
    });

/// Provides the currently active account for a given platform.
final activeAccountProvider = Provider.family<Account?, AiPlatform>((
  ref,
  platform,
) {
  final accounts = ref.watch(platformAccountsProvider(platform));
  return accounts.whenData((list) {
    try {
      return list.firstWhere((a) => a.isActive);
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }).value;
});
