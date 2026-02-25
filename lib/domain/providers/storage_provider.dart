/// Riverpod provider for secure local storage.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/secure_storage_service.dart';

/// Provides an instance of [SecureStorageService],
/// which wraps flutter_secure_storage.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
