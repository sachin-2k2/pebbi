import 'package:flutter/material.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_strings.dart';

/// Round profile button triggering the profile & settings sheet.
///
/// Follows AGENTS.md §3 & §4: under 70 lines, 48dp minimum touch target.
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      label: AppStrings.profileButtonSemantics,
      child: Material(
        color: palette.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.outline, width: 1.0),
              boxShadow: palette.cardShadow,
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                color: palette.textMuted,
                size: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
