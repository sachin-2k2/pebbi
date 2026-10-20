import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Store-compliance legal footer containing Terms, Privacy, and Restore links.
///
/// Follows AGENTS.md §3 & §4: under 150 lines, build under 50 lines,
/// 48dp tap targets, accessible labels.
///
/// TODO(question): App Store & Google Play guidelines require:
/// 1. Subscription automatically renews unless cancelled 24h prior to cycle end.
/// 2. Clear instructions that cancellation is managed in App Store/Google Play settings.
/// 3. Active functional URLs for Terms of Service (EULA) and Privacy Policy.
/// 4. Prominent "Restore Purchases" action for returning iOS subscribers.
class LegalFooter extends StatelessWidget {
  const LegalFooter({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.onRestoreTap,
  });

  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final VoidCallback? onRestoreTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDark ? AppColors.darkTextMuted : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          _linkButton(
            label: AppStrings.legalTerms,
            color: color,
            onTap: onTermsTap,
          ),
          Text('•', style: TextStyle(color: color, fontSize: 12.0)),
          _linkButton(
            label: AppStrings.legalPrivacy,
            color: color,
            onTap: onPrivacyTap,
          ),
          Text('•', style: TextStyle(color: color, fontSize: 12.0)),
          _linkButton(
            label: AppStrings.legalRestore,
            color: color,
            onTap: onRestoreTap,
          ),
        ],
      ),
    );
  }

  Widget _linkButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return TextButton(
      onPressed: onTap ?? () {},
      style: TextButton.styleFrom(
        minimumSize: const Size(48.0, 48.0),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 12.0,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
