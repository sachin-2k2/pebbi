import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../l10n/app_strings.dart';

/// Underlined link allowing learner to skip an audio exercise without penalty.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, 48dp minimum tap target.
/// Accessibility & context escape: skips item without penalty.
/// TODO(question): Confirm reading alternative for deaf and hard-of-hearing learners.
class CantListenLink extends StatelessWidget {
  const CantListenLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48.0, minWidth: 48.0),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: const Size(48.0, 48.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
          ),
          child: Semantics(
            link: true,
            label: AppStrings.cantListenNowSemantics,
            child: Text(
              AppStrings.cantListenNow,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandPurple,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.brandPurple,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
