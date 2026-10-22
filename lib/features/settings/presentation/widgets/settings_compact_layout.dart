import 'package:flutter/material.dart';
import '../../../../core/layout/content_width_limiter.dart';
import '../../../../core/theme/app_spacing.dart';
import 'settings_back_link.dart';
import 'settings_sections.dart';
import 'version_footer.dart';

/// Compact single-column scrolling layout for Settings.
///
/// Follows AGENTS.md §3: single-responsibility presentation layout widget.
class SettingsCompactLayout extends StatelessWidget {
  const SettingsCompactLayout({super.key, required this.sections});

  final SettingsSections sections;

  @override
  Widget build(BuildContext context) {
    return ContentWidthLimiter(
      maxWidth: AppSpacing.maxContentWidthCompact,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SettingsBackLink()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(child: sections.header),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.courses),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.goalReminders),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.soundHaptics),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.appearance),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.accessibility),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.account),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: sections.more),
          SliverToBoxAdapter(child: VersionFooter(version: sections.version)),
        ],
      ),
    );
  }
}
