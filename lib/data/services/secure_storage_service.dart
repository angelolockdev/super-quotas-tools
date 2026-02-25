/// Secure storage service wrapping [FlutterSecureStorage].
///
/// All OAuth tokens, JWT tokens, refresh tokens, and device
/// fingerprint secrets are stored through this service.
/// Keys are prefixed by account ID to avoid collisions.
///
/// SECURITY: No token value is ever logged, printed, or
/// included in error reports.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/utils/logger.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Android-specific options for encrypted shared preferences.
  static const _androidOptions = AndroidOptions(
    // ignore: deprecated_member_use
    encryptedSharedPreferences: true,
  );

  SecureStorageService()
    : _storage = const FlutterSecureStorage(aOptions: _androidOptions);

  /// Builds a namespaced key: `{accountId}_{key}`.
  String _buildKey(String accountId, String key) => '${accountId}_$key';

  /// Save a token securely.
  Future<void> saveToken({
    required String accountId,
    required String key,
    required String value,
  }) async {
    final nsKey = _buildKey(accountId, key);
    SafeLogger.info('Saving secure key: $nsKey');
    await _storage.write(key: nsKey, value: value);
  }

  /// Read a token. Returns `null` if not found.
  Future<String?> readToken({
    required String accountId,
    required String key,
  }) async {
    final nsKey = _buildKey(accountId, key);
    SafeLogger.info('Reading secure key: $nsKey');
    return _storage.read(key: nsKey);
  }

  /// Delete a specific token.
  Future<void> deleteToken({
    required String accountId,
    required String key,
  }) async {
    final nsKey = _buildKey(accountId, key);
    SafeLogger.info('Deleting secure key: $nsKey');
    await _storage.delete(key: nsKey);
  }

  /// Delete all tokens for a given account.
  Future<void> deleteAllForAccount(String accountId) async {
    SafeLogger.info('Deleting all secure keys for account $accountId');
    final all = await _storage.readAll();
    for (final entry in all.entries) {
      if (entry.key.startsWith('${accountId}_')) {
        await _storage.delete(key: entry.key);
      }
    }
  }

  /// Delete all stored secrets (e.g., on sign-out).
  Future<void> deleteAll() async {
    SafeLogger.info('Deleting all secure storage');
    await _storage.deleteAll();
  }
}
