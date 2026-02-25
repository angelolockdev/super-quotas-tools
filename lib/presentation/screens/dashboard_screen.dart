/// Main dashboard screen with platform cards grid,
/// quota gauges, and sync status.
///
/// This is the primary screen after login — shows a
/// 2-column grid of all 5 AI platforms with live quota
/// data, pull-to-refresh, and quick-switch actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/platform_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/providers/account_provider.dart';

import '../../domain/providers/theme_provider.dart';
import '../widgets/platform_summary_card.dart';

import 'platform_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              onRefresh: () => ref.read(accountsProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── App Bar ───────────────────────────────────
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent,
                                AppColors.accentSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.dashboard_customize_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Cockpit Tools'),
                      ],
                    ),
                    actions: [
                      // Theme toggle
                      IconButton(
                        onPressed: () =>
                            ref.read(themeModeProvider.notifier).toggle(),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            key: ValueKey(isDark),
                          ),
                        ),
                        tooltip: 'Toggle theme',
                      ),
                      // Settings
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.settings_outlined),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),

                  // ── Greeting Header ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your AI IDE accounts & quotas',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Sync Status Chip ──────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Synced',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          accountsAsync.when(
                            data: (accounts) => Text(
                              '${accounts.length} accounts',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (e, s) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // ── Platform Cards Grid ───────────────────────
                  accountsAsync.when(
                    data: (accounts) => SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          int crossAxisCount = 2;
                          double aspectRatio = 0.85;

                          if (width > 900) {
                            crossAxisCount = 4;
                            aspectRatio = 1.0;
                          } else if (width > 600) {
                            crossAxisCount = 3;
                            aspectRatio = 0.95;
                          }

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: aspectRatio,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final platform = AiPlatform.values[index];
                              final platformAccounts = accounts
                                  .where((a) => a.platform == platform)
                                  .toList();
                              final active = platformAccounts
                                  .where((a) => a.isActive)
                                  .toList();

                              return PlatformSummaryCard(
                                platform: platform,
                                accountCount: platformAccounts.length,
                                activeEmail: active.isNotEmpty
                                    ? active.first.email
                                    : null,
                                quotaRatio: 0.0, // Updated by realtime stream
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PlatformDetailScreen(
                                      platform: platform,
                                    ),
                                  ),
                                ),
                                onQuickSwitch: () =>
                                    _showQuickSwitch(context, ref, platform),
                              ).animate().fadeIn(
                                    delay: (index * 50).ms,
                                    duration: 400.ms,
                                  ).moveY(begin: 12, end: 0);
                            }, childCount: AiPlatform.values.length),
                          );
                        },
                      ),
                    ),
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          int crossAxisCount = 2;
                          if (width > 900) {
                            crossAxisCount = 4;
                          } else if (width > 600) {
                            crossAxisCount = 3;
                          }

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.85,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildShimmerCard(isDark),
                              childCount: 5,
                            ),
                          );
                        },
                      ),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 48,
                                color: AppColors.danger.withAlpha(150),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load accounts',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$e',
                                style: theme.textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Footer spacer ────────────────────────────
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildShimmerCard(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey.shade200,
      highlightColor: isDark ? Colors.white24 : Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showQuickSwitch(
    BuildContext context,
    WidgetRef ref,
    AiPlatform platform,
  ) {
    final accountsAsync = ref.read(platformAccountsProvider(platform));
    final brandColor = platform.brandColor;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return accountsAsync.when(
          data: (accounts) => ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Switch ${platform.label}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              final account = accounts[index - 1];
              return ListTile(
                leading: Icon(
                  account.isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: brandColor,
                ),
                title: Text(account.email),
                subtitle: Text(account.plan.name.toUpperCase()),
                onTap: () async {
                  await ref
                      .read(accountsProvider.notifier)
                      .switchAccount(account);
                  if (context.mounted) Navigator.of(context).pop();
                },
              );
            },
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Error: $e'),
          ),
        );
      },
    );
  }
}
