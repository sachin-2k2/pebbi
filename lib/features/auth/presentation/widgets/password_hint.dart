import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_strings.dart';

/// Accessible helper text explaining password length and security guidance.
///
/// Follows AGENTS.md §3 & §4: under 60 lines, WCAG AA contrast.
class PasswordHint extends StatelessWidget {
  const PasswordHint({
    super.key,
    this.text = AppStrings.authErrorPasswordTooShort,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
      child: Semantics(
        label: text,
        child: Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
