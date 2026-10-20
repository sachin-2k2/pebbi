import 'package:flutter/material.dart';
import '../../../../../core/layout/adaptive_sheet.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/language_level.dart';
import '../../../domain/level_info.dart';
import 'level_option_card.dart';

/// Modal bottom sheet (adaptive dialog on tablet) for selecting a language level.
///
/// Follows AGENTS.md §3 & §4: uses [AdaptiveSheet], under 100 lines, build under 50 lines.
class LevelPickerSheet extends StatelessWidget {
  const LevelPickerSheet({super.key, required this.selectedLevel});

  final LanguageLevel selectedLevel;

  /// Helper to show this level picker via [AdaptiveSheet].
  static Future<LanguageLevel?> show({
    required BuildContext context,
    required LanguageLevel selectedLevel,
  }) {
    return AdaptiveSheet.show<LanguageLevel>(
      context: context,
      maxWidth: 480.0,
      builder: (sheetContext) => LevelPickerSheet(selectedLevel: selectedLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.chooseADifferentLevel,
                      style: AppTypography.cardTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < LevelInfo.allLevels.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                LevelOptionCard(
                  levelInfo: LevelInfo.allLevels[i],
                  isSelected: selectedLevel == LevelInfo.allLevels[i].level,
                  onTap: () =>
                      Navigator.of(context).pop(LevelInfo.allLevels[i].level),
                  index: i + 1,
                  total: LevelInfo.allLevels.length,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
