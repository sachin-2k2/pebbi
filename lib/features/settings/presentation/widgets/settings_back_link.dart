import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/back_link.dart';
import '../../../../l10n/app_strings.dart';

/// Top back link for the settings screen switching back to the Home Path tab.
///
/// Follows AGENTS.md §3 & §7.1: reuses shared BackLink, switches tab rather than pushing.
class SettingsBackLink extends StatelessWidget {
  const SettingsBackLink({super.key});

  @override
  Widget build(BuildContext context) {
    return BackLink(
      label: AppStrings.settingsBackToPath,
      onTap: () => context.go('/path'),
    );
  }
}
