import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Calm system banner rendered in the chat stream when all goals are completed.
///
/// Follows AGENTS.md §7.3 & §10:
/// - Informs user that goals are done without forcing the session to end
/// - TODO(question: system note styling estimated with info palette tokens)
class SystemNote extends StatelessWidget {
  const SystemNote({
    super.key,
    this.text = AppStrings.sessionAllGoalsDone,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: palette.infoSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: palette.infoBorder, width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: palette.mint,
              size: 16.0,
            ),
            const SizedBox(width: AppSpacing.xs + 2.0),
            Flexible(
              child: Text(
                text,
                style: AppTypography.caption.copyWith(
                  color: palette.infoText,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
