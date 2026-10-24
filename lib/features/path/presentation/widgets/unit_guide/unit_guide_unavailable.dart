import 'package:flutter/material.dart';
import '../../../../../core/design_system/button_3d.dart';
import '../../../../../core/design_system/empty_state.dart';
import '../../../../../core/design_system/pebbi_mascot.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../l10n/app_strings.dart';

/// Empty state presented when a unit guidebook is not yet available for a language.
///
/// Follows AGENTS.md §3: under 100 lines, build under 50 lines.
class UnitGuideUnavailable extends StatelessWidget {
  const UnitGuideUnavailable({
    super.key,
    required this.onClosePressed,
    this.title = AppStrings.unitGuideUnavailableTitle,
    this.message = AppStrings.unitGuideUnavailableMessage,
  });

  final VoidCallback onClosePressed;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return EmptyState(
      illustration: const PebbiMascot(
        size: 96.0,
        expression: PebbiExpression.winking,
      ),
      title: title,
      subtitle: message,
      action: Button3D(
        label: AppStrings.closeGuidebook,
        onPressed: onClosePressed,
        backgroundColor: palette.brand,
        depthColor: palette.brandDepth,
        textColor: palette.textOnBrand,
      ),
    );
  }
}
