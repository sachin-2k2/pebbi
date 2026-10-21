import 'package:flutter/material.dart';
import '../../../../../core/design_system/selectable_pill_chip.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_strings.dart';
import '../../../domain/correction_style.dart';

/// Single-choice 3-pill selector for [CorrectionStyle] options.
///
/// Follows AGENTS.md §3, §4.6 (minimum 48dp tap target), & WCAG AA:
/// - Reuses [SelectablePillChip] in its small variant.
/// - Selected pill displays checkmark icon so distinction does not rely on color alone.
class CorrectionStyleSelector extends StatelessWidget {
  const CorrectionStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  final CorrectionStyle selectedStyle;
  final ValueChanged<CorrectionStyle> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppStrings.correctionStyleLabel,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          _buildPill(
            style: CorrectionStyle.gentle,
            label: AppStrings.correctionStyleGentle,
          ),
          _buildPill(
            style: CorrectionStyle.live,
            label: AppStrings.correctionStyleLive,
          ),
          _buildPill(
            style: CorrectionStyle.none,
            label: AppStrings.correctionStyleNone,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({required CorrectionStyle style, required String label}) {
    final isSelected = style == selectedStyle;

    return SelectablePillChip(
      label: label,
      isSelected: isSelected,
      size: SelectablePillChipSize.small,
      showCheckIcon: true,
      onTap: () => onStyleSelected(style),
      semanticsLabel: AppStrings.correctionStyleSemantics(
        style: label,
        isSelected: isSelected,
      ),
    );
  }
}
