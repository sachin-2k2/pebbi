import 'package:flutter/material.dart';
import '../../../../../core/design_system/back_link.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Screen view displayed when a role-play mission is not available in the selected language.
///
/// Follows AGENTS.md §7.3 & §3.
class SessionUnavailableView extends StatelessWidget {
  const SessionUnavailableView({super.key, required this.targetLanguageName});

  final String targetLanguageName;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackLink(label: AppStrings.missionsLink),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌍', style: TextStyle(fontSize: 48.0)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  AppStrings.sessionLanguageUnavailableTitle,
                  style: AppTypography.screenTitle.copyWith(color: palette.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.sessionLanguageUnavailableBody(targetLanguageName),
                  style: AppTypography.bodyMedium.copyWith(color: palette.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
