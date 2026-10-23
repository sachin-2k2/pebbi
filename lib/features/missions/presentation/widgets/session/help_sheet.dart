import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Modal sheet for Help and scene guidance.
///
/// Follows AGENTS.md §9:
/// - Three estimated options: Show hint, Translate last message, Leave mission
/// - TODO(question: Help options are estimated)
class HelpSheet extends StatelessWidget {
  const HelpSheet({
    super.key,
    required this.onShowHint,
    required this.onTranslateLast,
    required this.onLeave,
  });

  final VoidCallback onShowHint;
  final VoidCallback onTranslateLast;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final options = [
      (
        icon: Icons.lightbulb_outline_rounded,
        label: AppStrings.helpOptionShowHint,
        onTap: () {
          Navigator.of(context).pop();
          onShowHint();
        },
      ),
      (
        icon: Icons.subtitles_outlined,
        label: AppStrings.helpOptionTranslateLast,
        onTap: () {
          Navigator.of(context).pop();
          onTranslateLast();
        },
      ),
      (
        icon: Icons.exit_to_app_rounded,
        label: AppStrings.helpOptionLeave,
        onTap: () {
          Navigator.of(context).pop();
          onLeave();
        },
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.helpSheetTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final opt in options)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: Icon(opt.icon, color: palette.brand),
                  title: Text(
                    opt.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: palette.textMuted),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    side: BorderSide(color: palette.outline),
                  ),
                  onTap: opt.onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
