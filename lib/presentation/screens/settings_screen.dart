/// Settings screen for theme, language, and account actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/providers/auth_provider.dart';
import '../../domain/providers/theme_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── User section ──────────────────────────────
              if (user != null) ...[
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentSecondary.withAlpha(30),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.accentSecondary,
                      ),
                    ),
                    title: Text(
                      user.email ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Supabase Account'),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Appearance ────────────────────────────────
              _buildSectionHeader(theme, 'Appearance'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        isDark ? 'Currently dark' : 'Currently light',
                      ),
                      secondary: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (_) =>
                          ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── About ─────────────────────────────────────
              _buildSectionHeader(theme, 'About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Version'),
                      trailing: Text('0.1.0', style: theme.textTheme.bodySmall),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code_rounded),
                      title: const Text('Cockpit Tools'),
                      subtitle: const Text('AI IDE Account Manager'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Sign Out ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final repo = ref.read(authRepositoryProvider);
                    await repo.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.accentSecondary,
        ),
      ),
    );
  }
}
