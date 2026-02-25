/// Platform detail screen showing the account list
/// and quota breakdown for a specific AI IDE platform.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/platform_constants.dart';
import '../../domain/providers/account_provider.dart';
import '../../domain/providers/quota_provider.dart';
import '../widgets/account_tile.dart';
import '../widgets/quota_gauge_card.dart';
import '../widgets/quick_switch_button.dart';
import 'add_account_screen.dart';

class PlatformDetailScreen extends ConsumerWidget {
  final AiPlatform platform;

  const PlatformDetailScreen({super.key, required this.platform});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(platformAccountsProvider(platform));
    final theme = Theme.of(context);
    final brandColor = platform.brandColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              platform.svgPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(brandColor, BlendMode.srcIn),
              placeholderBuilder: (ctx) =>
                  Icon(platform.icon, color: brandColor, size: 24),
            ),
            const SizedBox(width: 10),
            Text(platform.label),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddAccountScreen(initialPlatform: platform),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Account',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: accountsAsync.when(
            data: (accounts) {
              if (accounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        platform.svgPath,
                        width: 64,
                        height: 64,
                        colorFilter:
                            ColorFilter.mode(brandColor, BlendMode.srcIn),
                        placeholderBuilder: (ctx) => Icon(
                          platform.icon,
                          size: 64,
                          color: brandColor.withAlpha(80),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No accounts yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first ${platform.label} account\nfrom the desktop app to sync here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  // ── Section: Accounts ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      'Accounts (${accounts.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: brandColor,
                      ),
                    ),
                  ),
                  ...accounts.map(
                    (account) => AccountTile(
                      account: account,
                      onSwitch: () async {
                        await ref
                            .read(accountsProvider.notifier)
                            .switchAccount(account);
                      },
                      onDelete: () {
                        // TODO: confirm deletion dialog
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Section: Quotas for Active Account ─────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Text(
                      'Quota Overview',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: brandColor,
                      ),
                    ),
                  ),

                  // Show quotas for the active account
                  _buildQuotaSection(ref, accounts, theme),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
      floatingActionButton: QuickSwitchButton(platform: platform),
    );
  }

  Widget _buildQuotaSection(WidgetRef ref, List accounts, ThemeData theme) {
    final active = accounts.where((a) => a.isActive).toList();
    if (active.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Select an active account to view quotas',
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    final quotasAsync = ref.watch(quotaStreamProvider(active.first.id));

    return quotasAsync.when(
      data: (quotas) {
        if (quotas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No quota data available yet.\nSync from the desktop app.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            int crossAxisCount = 2;
            if (width > 800) {
              crossAxisCount = 4;
            } else if (width > 500) {
              crossAxisCount = 3;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: quotas.length,
                itemBuilder: (_, index) {
                  final q = quotas[index];
                  return QuotaGaugeCard(
                    label: q.label,
                    used: q.used,
                    limit: q.limit,
                    accentColor: platform.brandColor,
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Quota error: $e'),
      ),
    );
  }
}
