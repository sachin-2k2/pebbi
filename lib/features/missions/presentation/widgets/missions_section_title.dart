import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Section header heading for "Situations".
class MissionsSectionTitle extends StatelessWidget {
  const MissionsSectionTitle({
    super.key,
    this.title = AppStrings.situationsTitle,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          title,
          style: AppTypography.screenTitle.copyWith(
            fontSize: 20.0,
            color: context.palette.textPrimary,
          ),
        ),
      ),
    );
  }
}
