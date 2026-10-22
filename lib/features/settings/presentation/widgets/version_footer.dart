import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Centered muted footer line displaying application version.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, ample bottom padding for tab bar.
class VersionFooter extends StatelessWidget {
  const VersionFooter({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xxl + 24.0,
      ),
      child: Center(
        child: Text(
          AppStrings.settingsVersion(version),
          style: AppTypography.captionSmall.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
