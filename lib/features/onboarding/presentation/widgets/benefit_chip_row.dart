import 'package:flutter/material.dart';
import '../../../../core/design_system/benefit_chip.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_strings.dart';

/// Flow wrapping row displaying the three placement benefit chips:
/// "No timer", "Skip anything", and "Ends in a win".
///
/// Follows AGENTS.md §3 & §4: under 100 lines, build under 50 lines,
/// wraps on narrow widths or at 200% text scale without overflow.
class BenefitChipRow extends StatelessWidget {
  const BenefitChipRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.start,
      children: [
        BenefitChip(label: AppStrings.placementChipNoTimer),
        BenefitChip(label: AppStrings.placementChipSkipAnything),
        BenefitChip(label: AppStrings.placementChipEndsInAWin),
      ],
    );
  }
}
