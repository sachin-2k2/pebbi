import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';
import '../../../../domain/phrase_token.dart';

/// Individual tappable word token within a phrase card.
///
/// Follows AGENTS.md §3 & §4: 48dp tap area, accessible semantics.
/// Visual state estimated: soft lavender fill with a tiny star when saved.
/// TODO(question): Confirm saved token design with product/design team.
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
    final semanticLabel = isSaved
        ? AppStrings.tokenTappedSaved(token.text)
        : AppStrings.tokenTapToSave(token.text);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
        child: Material(
          color: isSaved ? const Color(0xFFEDE9FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: isSaved
                    ? Border.all(color: AppColors.brandPurple, width: 1.5)
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSaved) ...[
                    const SizedBox(width: AppSpacing.xxs),
                    const Icon(
                      Icons.star_rounded,
                      size: 16.0,
                      color: AppColors.brandPurple,
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
