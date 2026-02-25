/// Circular quota gauge widget.
///
/// Displays a usage ratio as an animated circular progress
/// indicator with color that shifts green → amber → red.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/theme/app_colors.dart';

class QuotaGaugeCard extends StatelessWidget {
  /// Human-readable label (e.g., "Claude 3.5 Sonnet").
  final String label;

  /// Current usage count.
  final int used;

  /// Maximum allowed.
  final int limit;

  /// Optional reset time string.
  final String? resetLabel;

  /// Outer card color override.
  final Color? accentColor;

  const QuotaGaugeCard({
    super.key,
    required this.label,
    required this.used,
    required this.limit,
    this.resetLabel,
    this.accentColor,
  });

  double get _ratio => limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gaugeColor = accentColor ?? AppColors.quotaColor(_ratio);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Circular Gauge ──────────────────────────────
            CircularPercentIndicator(
              radius: 40,
              lineWidth: 8,
              percent: _ratio,
              animation: true,
              animationDuration: 800,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: gaugeColor,
              backgroundColor: gaugeColor.withAlpha(40),
              center: Text(
                '${(_ratio * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: gaugeColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Label ───────────────────────────────────────
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // ── Usage fraction ──────────────────────────────
            Text(
              '$used / $limit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),

            // ── Reset label ─────────────────────────────────
            if (resetLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                'Resets $resetLabel',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
