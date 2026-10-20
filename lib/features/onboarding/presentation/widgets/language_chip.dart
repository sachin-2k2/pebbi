import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';
import '../../domain/language_option.dart';

/// Single selectable language chip displaying script glyph, native name,
/// and an animated check icon when selected.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, min 48dp tap target,
/// inner Directionality support for RTL scripts (Arabic, Urdu).
class LanguageChip extends StatelessWidget {
  const LanguageChip({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.tintLavender : AppColors.surface;
    final borderColor = isSelected
        ? AppColors.brandPurple
        : AppColors.borderLight;
    final textColor = isSelected
        ? AppColors.brandPurple
        : AppColors.textPrimary;
    final textDirection = language.isRtl
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Semantics(
      button: true,
      selected: isSelected,
      label: AppStrings.languageChipSemantics(language.nativeName, isSelected),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          side: BorderSide(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Directionality(
              textDirection: textDirection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.badgeGlyph,
                    style: AppTypography.screenTitle.copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      language.nativeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.screenTitle.copyWith(
                        fontSize: 16.0,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.check, size: 18.0, color: AppColors.brandPurple),
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
