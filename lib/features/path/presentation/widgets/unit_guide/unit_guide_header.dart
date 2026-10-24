import 'package:flutter/material.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/app_strings.dart';

/// Top section of unit guidebook sheet containing drag handle, title, and close action.
///
/// Follows AGENTS.md §3 & §8: under 100 lines, accessible semantics, responsive typography.
class UnitGuideHeader extends StatelessWidget {
  const UnitGuideHeader({
    super.key,
    required this.title,
    this.subtitle = AppStrings.unitGuideSubtitle,
    required this.onClosePressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClosePressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ExcludeSemantics(
            child: Container(
              width: 36.0,
              height: 4.0,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: palette.outline,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: AppTypography.screenTitle.copyWith(
                        color: palette.textPrimary,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: palette.textMuted,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: palette.textMuted),
              iconSize: 22.0,
              tooltip: AppStrings.closeGuidebook,
              constraints: const BoxConstraints(
                minWidth: 48.0,
                minHeight: 48.0,
              ),
              onPressed: onClosePressed,
            ),
          ],
        ),
      ],
    );
  }
}
