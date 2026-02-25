/// Expandable account tile for platform detail screens.
///
/// Shows account email, plan, tags, and active status.
/// Expands to reveal quota details and action buttons.
library;

import 'package:flutter/material.dart';

import '../../core/constants/platform_constants.dart';
import '../../data/models/account_model.dart';

class AccountTile extends StatelessWidget {
  final Account account;
  final VoidCallback? onSwitch;
  final VoidCallback? onDelete;

  const AccountTile({
    super.key,
    required this.account,
    this.onSwitch,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandColor = account.platform.brandColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: account.isActive
            ? Border.all(color: brandColor, width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: brandColor.withAlpha(30),
          child: Icon(
            account.isActive ? Icons.check_circle : Icons.account_circle,
            color: brandColor,
          ),
        ),
        title: Text(
          account.email,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${account.plan.name.toUpperCase()} · ${account.tags.join(", ")}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!account.isActive)
              IconButton(
                onPressed: onSwitch,
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Switch to this account',
                color: brandColor,
              ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Remove account',
              color: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
