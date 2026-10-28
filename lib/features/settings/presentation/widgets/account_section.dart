import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';
import '../../../auth/domain/user_profile.dart';
import 'destructive_tile.dart';
import 'settings_action_pill.dart';
import 'settings_info_tile.dart';
import 'settings_section_card.dart';

/// Account section card adapting between Guest, Signed-in, and Premium user sessions.
///
/// Follows AGENTS.md §3 & §6: under 150 lines, build under 50 lines, user isolation.
class AccountSection extends StatelessWidget {
  const AccountSection({
    super.key,
    required this.userProfile,
    required this.onSignIn,
    required this.onSeeOptions,
    required this.onResetProgress,
    this.onLogOut,
  });

  final UserProfile? userProfile;
  final VoidCallback onSignIn;
  final VoidCallback onSeeOptions;
  final VoidCallback onResetProgress;
  final VoidCallback? onLogOut;

  bool get _isGuest =>
      userProfile == null || userProfile!.userId.startsWith('guest_');

  String get _accountSubtitle {
    final email = userProfile?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return userProfile?.userId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsSectionCard(
      emoji: '🔑',
      title: AppStrings.settingsAccountTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isGuest) ...[
            SettingsInfoTile(
              icon: _AccountIconBox(
                icon: Icons.lock_outline_rounded,
                color: AppColors.brandPurple,
                isDark: isDark,
              ),
              title: AppStrings.settingsGuestModeTitle,
              subtitle: AppStrings.settingsGuestModeSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsInfoTile(
              icon: _AccountIconBox(
                icon: Icons.cloud_outlined,
                color: AppColors.accentSky,
                isDark: isDark,
              ),
              title: AppStrings.settingsSignInTitle,
              subtitle: AppStrings.settingsSignInSubtitle,
              trailing: SettingsActionPill(
                label: AppStrings.settingsSignInAction,
                onTap: onSignIn,
              ),
            ),
          ] else ...[
            SettingsInfoTile(
              icon: _AccountIconBox(
                icon: Icons.account_circle_outlined,
                color: AppColors.brandPurple,
                isDark: isDark,
              ),
              title: AppStrings.settingsAccountSignedTitle,
              subtitle: _accountSubtitle,
              trailing: SettingsActionPill(
                label: AppStrings.settingsLogOutAction,
                onTap: onLogOut ?? () {},
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SettingsInfoTile(
            icon: _AccountIconBox(
              icon: Icons.workspace_premium_outlined,
              color: AppColors.coral,
              isDark: isDark,
            ),
            title: AppStrings.settingsFreePlanTitle,
            subtitle: AppStrings.settingsFreePlanSubtitle,
            trailing: SettingsActionPill(
              label: AppStrings.settingsSeeOptionsAction,
              onTap: onSeeOptions,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DestructiveTile(onTap: onResetProgress),
        ],
      ),
    );
  }
}

class _AccountIconBox extends StatelessWidget {
  const _AccountIconBox({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.0,
      height: 38.0,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20.0, color: color),
    );
  }
}
