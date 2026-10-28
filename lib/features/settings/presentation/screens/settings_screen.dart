import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/layout/two_pane_layout.dart';
import '../../../../core/layout/window_class.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_section_provider.dart';
import '../widgets/settings_compact_layout.dart';
import '../widgets/settings_left_pane.dart';
import '../widgets/settings_right_pane.dart';
import '../widgets/settings_sections.dart';

/// App Settings screen (fifth tab of AdaptiveShell).
///
/// Follows AGENTS.md §3 (<100 lines) & §4 (TwoPane on expanded, zero overflow).
/// Automatically refreshes the authenticated user profile via `GET /api/me`.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentUserProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections = SettingsSections.from(context, ref);
    final selectedSection = ref.watch(selectedSettingsSectionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: TwoPaneLayout(
          primaryFlex: 2,
          secondaryFlex: 3,
          primaryPane: context.isExpanded
              ? SettingsLeftPane(
                  header: sections.header,
                  selectedSection: selectedSection,
                  onSelectSection: (s) =>
                      ref.read(selectedSettingsSectionProvider.notifier).state =
                          s,
                )
              : SettingsCompactLayout(sections: sections),
          secondaryPane: SettingsRightPane(
            selectedSection: selectedSection,
            sections: sections,
          ),
        ),
      ),
    );
  }
}
