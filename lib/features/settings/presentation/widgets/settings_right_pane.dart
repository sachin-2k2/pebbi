import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/settings_section_provider.dart';
import 'settings_sections.dart';
import 'version_footer.dart';

/// Right content pane for Settings in expanded tablet viewports.
///
/// Follows AGENTS.md §3 & §4.3: under 100 lines, build under 50 lines.
class SettingsRightPane extends StatelessWidget {
  const SettingsRightPane({
    super.key,
    required this.selectedSection,
    required this.sections,
  });

  final SettingsSectionId selectedSection;
  final SettingsSections sections;

  Widget _buildSection() {
    switch (selectedSection) {
      case SettingsSectionId.courses:
        return sections.courses;
      case SettingsSectionId.goalReminders:
        return sections.goalReminders;
      case SettingsSectionId.soundHaptics:
        return sections.soundHaptics;
      case SettingsSectionId.appearance:
        return sections.appearance;
      case SettingsSectionId.accessibility:
        return sections.accessibility;
      case SettingsSectionId.account:
        return sections.account;
      case SettingsSectionId.more:
        return sections.more;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(),
          VersionFooter(version: sections.version),
        ],
      ),
    );
  }
}
