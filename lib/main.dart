/// Cockpit Tools — AI IDE Account & Quota Manager (Mobile)
///
/// Entry point: initializes Supabase, sets up Riverpod,
/// configures light/dark theme, and routes to splash screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'domain/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize Supabase ─────────────────────────────────
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    SafeLogger.info('Supabase initialized');
  } catch (e, st) {
    SafeLogger.error('Supabase init failed', error: e, stackTrace: st);
  }

  // ── Launch app with Riverpod ────────────────────────────
  runApp(const ProviderScope(child: CockpitToolsApp()));
}

/// Root application widget.
///
/// Watches [themeModeProvider] and reactively switches
/// between the light and dark Material 3 themes.
class CockpitToolsApp extends ConsumerWidget {
  const CockpitToolsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Cockpit Tools',
      debugShowCheckedModeBanner: false,

      // ── Theming ───────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // ── Entry Screen ──────────────────────────────────
      home: const SplashScreen(),
    );
  }
}
