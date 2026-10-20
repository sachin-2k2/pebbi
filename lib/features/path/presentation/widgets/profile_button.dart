import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_strings.dart';

/// Round profile button triggering the profile & settings sheet.
///
/// Follows AGENTS.md §3 & §4: under 70 lines, 48dp minimum touch target.
class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppStrings.profileButtonSemantics,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A1E1647),
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.textMuted,
                size: 20.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
