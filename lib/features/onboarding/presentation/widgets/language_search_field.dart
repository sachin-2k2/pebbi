import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Rounded search field for filtering language options.
///
/// Follows AGENTS.md §3 and §4: under 100 lines, min 48dp tap target,
/// theme tokens, accessible semantics.
class LanguageSearchField extends StatelessWidget {
  const LanguageSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: AppStrings.searchLanguagesPlaceholder,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 22.0,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18.0),
                    color: AppColors.textMuted,
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                      if (onClear != null) onClear!();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ),
    );
  }
}
