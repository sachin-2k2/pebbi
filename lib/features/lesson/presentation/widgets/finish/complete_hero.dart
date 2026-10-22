import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../../settings/presentation/providers/app_settings_provider.dart';

/// Top hero section for the Lesson Complete screen.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// displays excited mascot with user accent color, large header title, and encouraging subtitle.
class CompleteHero extends ConsumerWidget {
  const CompleteHero({
    super.key,
    required this.starsEarned,
  });

  final int starsEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ref.watch(accentColorProvider);

    final titleColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.darkTextMuted
        : const Color(0xFF524F6B); // WCAG AA compliant (5.5:1 on background)

    final subtitle = AppStrings.lessonCompleteSubtitleForStars(starsEarned);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.sm),
        ExcludeSemantics(
          child: PebbiMascot(
            size: 92.0,
            accentColor: accentColor,
            expression: PebbiExpression.excited,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            AppStrings.lessonCompleteTitle,
            style: AppTypography.screenTitle.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
              fontSize: 26.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: subtitleColor,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
