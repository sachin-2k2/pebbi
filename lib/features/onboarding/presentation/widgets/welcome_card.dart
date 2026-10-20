import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/welcome_page_data.dart';
import 'welcome_chip.dart';

/// Rounded tinted card presenting the mascot, title, subtitle, and highlight chips.
///
/// Follows AGENTS.md §3 and §4: build under 50 lines, no fixed layout sizes,
/// adapts to dark mode and scalable text.
class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key, required this.data});

  final WelcomePageData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurfaceVariant : data.cardTint;
    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PebbiMascot(
            size: 130.0,
            accentColor: data.buttonColor,
            expression: data.mascotExpression,
            outfit: data.mascotOutfit,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            data.title,
            style: AppTypography.screenTitle.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: subtitleColor,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: data.chips.map((c) => WelcomeChip(label: c)).toList(),
          ),
        ],
      ),
    );
  }
}
