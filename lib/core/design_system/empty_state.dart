import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable empty state view with mascot/illustration, title, subtitle, and optional footer.
///
/// Follows AGENTS.md §3 (<100 lines, build <50 lines) & §4.6.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.footer,
    this.action,
  });

  final Widget illustration;
  final String title;
  final String subtitle;
  final Widget? footer;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            illustration,
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(
                color: titleColor,
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320.0),
              child: Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: subtitleColor,
                  fontSize: 14.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: AppSpacing.lg),
              footer!,
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
