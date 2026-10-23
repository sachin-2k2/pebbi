import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_palette.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/phrase_token.dart';

/// Individual tappable word token within a phrase card.
///
/// Follows AGENTS.md §3 & §4: 48dp tap area, accessible semantics.
/// Word token renders cleanly with zero murky grey ink smudges when unsaved.
class PhraseTokenWidget extends StatelessWidget {
  const PhraseTokenWidget({
    super.key,
    required this.token,
    required this.isSaved,
    required this.onTap,
  });

  final PhraseToken token;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final semanticLabel = isSaved
        ? AppStrings.tokenTappedSaved(token.text)
        : AppStrings.tokenTapToSave(token.text);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
        child: Material(
          color: isSaved ? palette.brandTint : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            highlightColor: Colors.transparent,
            splashColor: palette.brandTint.withValues(alpha: 0.3),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: isSaved
                    ? Border.all(color: palette.brand, width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      token.text,
                      style: AppTypography.display.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSaved ? palette.brandText : palette.textPrimary,
                      ),
                    ),
                  ),
                  if (isSaved) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    Icon(
                      Icons.star_rounded,
                      size: 16.0,
                      color: palette.brand,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
