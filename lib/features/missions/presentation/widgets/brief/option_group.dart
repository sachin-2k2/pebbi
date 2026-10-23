import 'package:flutter/material.dart';
import '../../../../../core/design_system/section_label.dart';
import '../../../../../core/theme/app_spacing.dart';

/// Generic option group: a section label above a row of single-choice pills.
///
/// Follows AGENTS.md §3: Reusable across Mode, Support, and future Correction Style selectors.
class OptionGroup extends StatelessWidget {
  const OptionGroup({
    super.key,
    required this.title,
    required this.children,
    this.spacing = AppSpacing.sm,
  });

  final String title;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionLabel(text: title),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ],
    );
  }
}
