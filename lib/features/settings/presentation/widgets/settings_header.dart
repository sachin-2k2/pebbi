import 'package:flutter/material.dart';
import '../../../../core/design_system/pebbi_mascot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../../onboarding/domain/age_band.dart';
import '../../../onboarding/domain/learnable_language.dart';
import '../../../onboarding/domain/level_info.dart';
import '../../domain/name_safety_rules.dart';
import 'name_field.dart';

/// Top settings header displaying mascot, name field, and user learning status subtitle.
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines, responsive constraints.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.targetLanguage,
    required this.levelInfo,
    this.initialName,
    required this.onNameSaved,
    this.ageBand = AgeBand.adult,
  });

  final LearnableLanguage targetLanguage;
  final LevelInfo levelInfo;
  final String? initialName;
  final ValueChanged<String?> onNameSaved;
  final AgeBand ageBand;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showName = NameSafetyRules.shouldAskForName(ageBand);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const PebbiMascot(
              size: 54.0,
              expression: PebbiExpression.happy,
              outfit: PebbiOutfit.scarf,
            ),
            const SizedBox(width: AppSpacing.md),
            if (showName)
              Expanded(
                child: NameField(
                  initialName: initialName,
                  onSaved: onNameSaved,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
            AppStrings.settingsSubtitle(
              targetLanguage.englishName,
              levelInfo.name,
            ),
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
