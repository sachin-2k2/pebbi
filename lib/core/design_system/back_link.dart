import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable top-left back link with chevron and bold label.
///
/// Follows AGENTS.md §3 & §4.6:
/// - Minimum 48dp tap target for accessibility.
/// - Reused across Emergency Phrasebook ("< Missions") and Settings ("< Back to the path").
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.label, this.onTap});

  /// The label displayed beside the chevron (e.g. 'Missions', 'Back to the path').
  final String label;

  /// Optional navigation callback. Falls back to [context.pop] if omitted.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.pop(),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 20.0,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 2.0),
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
