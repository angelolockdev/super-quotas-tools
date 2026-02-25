/// One-click account switch floating action button.
///
/// Presents a bottom sheet with all accounts for a
/// platform, allowing instant switching.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/platform_constants.dart';
import '../../data/models/account_model.dart';
import '../../domain/providers/account_provider.dart';
import '../screens/add_account_screen.dart';

class QuickSwitchButton extends ConsumerWidget {
  final AiPlatform platform;

  const QuickSwitchButton({super.key, required this.platform});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      heroTag: 'quick_switch_${platform.name}',
      onPressed: () => _showSwitchSheet(context, ref),
      icon: const Icon(Icons.swap_horiz_rounded),
      label: const Text('Switch'),
    );
  }

  void _showSwitchSheet(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.read(platformAccountsProvider(platform));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.7,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return accountsAsync.when(
              data: (accounts) =>
                  _buildAccountList(context, ref, accounts, controller),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            );
          },
        );
      },
    );
  }

  Widget _buildAccountList(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
    ScrollController controller,
  ) {
    final brandColor = platform.brandColor;

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length + 2, // +1 for header, +1 for Add button
      itemBuilder: (ctx, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Switch ${platform.label} Account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          );
        }

        if (index == accounts.length + 1) {
          return ListTile(
            leading: Icon(Icons.add_circle_outline_rounded, color: brandColor),
            title: Text('Add ${platform.label} Account'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddAccountScreen(initialPlatform: platform),
                ),
              );
            },
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
            final notifier = ref.read(accountsProvider.notifier);
            await notifier.switchAccount(account);
            if (context.mounted) Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
