/// Platform summary card for the dashboard grid.
///
/// Shows the platform icon, active account count, a mini
/// quota gauge, and a quick-switch action button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/constants/platform_constants.dart';
import '../../core/theme/app_colors.dart';

class PlatformSummaryCard extends StatelessWidget {
  /// The AI IDE platform represented.
  final AiPlatform platform;

  /// Number of accounts registered for this platform.
  final int accountCount;

  /// The active account email (if any).
  final String? activeEmail;

  /// Aggregate quota usage ratio (0.0 – 1.0).
  final double quotaRatio;

  /// Callback when the user taps the card.
  final VoidCallback? onTap;

  /// Callback when the user presses the quick-switch button.
  final VoidCallback? onQuickSwitch;

  const PlatformSummaryCard({
    super.key,
    required this.platform,
    this.accountCount = 0,
    this.activeEmail,
    this.quotaRatio = 0.0,
    this.onTap,
    this.onQuickSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandColor = platform.brandColor;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: brandColor.withAlpha(isDark ? 60 : 30),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: brandColor.withAlpha(isDark ? 25 : 15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ──────────────────────────────
              Row(
                children: [
                  // Platform icon badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: brandColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      platform.svgPath,
                      colorFilter: ColorFilter.mode(brandColor, BlendMode.srcIn),
                      width: 22,
                      height: 22,
                      placeholderBuilder: (ctx) => Icon(
                        platform.icon,
                        color: brandColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Quick-switch button
                  if (accountCount > 1)
                    IconButton(
                      onPressed: onQuickSwitch,
                      icon: const Icon(Icons.swap_horiz_rounded),
                      iconSize: 20,
                      tooltip: 'Quick Switch',
                      style: IconButton.styleFrom(
                        backgroundColor: brandColor.withAlpha(20),
                        foregroundColor: brandColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Platform Name ───────────────────────────
              Text(
                platform.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // ── Active account ──────────────────────────
              Text(
                activeEmail ?? 'No account',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // ── Mini quota bar ──────────────────────────
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: 6,
                percent: quotaRatio.clamp(0.0, 1.0),
                animation: true,
                animationDuration: 800,
                barRadius: const Radius.circular(3),
                progressColor: AppColors.quotaColor(quotaRatio),
                backgroundColor: AppColors.quotaColor(quotaRatio).withAlpha(30),
              ),
              const SizedBox(height: 6),

              // ── Account count badge ─────────────────────
              Text(
                '$accountCount account${accountCount == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: brandColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).moveY(begin: 12, end: 0);
  }
}
